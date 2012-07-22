//
//  InfoEditViewController.m
//  MyLibrary
//
//  Created by 罗 泽响 on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "EditBookInfoViewController.h"
#import "BookInfoDownloader.h"

@interface EditBookInfoViewController () {
    MBProgressHUD *_HUD;
    BookInfoDownloader *_biDownloader;
    NSString *_tempISBN;
    NSUndoManager *_undoManager;
}
@end

@implementation EditBookInfoViewController
@synthesize isbnText = _isbnText;
@synthesize booknameText = _booknameText;
@synthesize authorText = _authorText;

@synthesize bookToSave = _bookToSave;
@synthesize managedObjectContext = _managedObjectContext;

#pragma mark - ViewController lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // start record actions to _managedObjectContext, that we can drop all actions after user cancle 
    _undoManager = [[NSUndoManager alloc] init];
    [_managedObjectContext setUndoManager:_undoManager];
    [_undoManager beginUndoGrouping];
    
    // !_bookToSave means call from AddbookSegue, otherwise from editBookInfoView
    if (!_bookToSave) {
        _bookToSave = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:_managedObjectContext];
    }
    
    _booknameText.delegate = self;
    _isbnText.delegate = self;
    _authorText.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated {
    [self refreshViews];
}

- (void)viewDidUnload
{
    [self setIsbnText:nil];
    [self setBooknameText:nil];
    [self setAuthorText:nil];
    [super viewDidUnload];
}

- (void) refreshViews {
    if (_bookToSave) {
        _booknameText.text = [[_bookToSave valueForKey:@"name"] description];
        _authorText.text = [[_bookToSave valueForKey:@"author"] description];
        _isbnText.text = [[_bookToSave valueForKey:@"isbn"] description];
    }
}

#pragma mark - scan isbn actions

- (IBAction)scanButtonTapped:(UIBarButtonItem *)sender {
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    // only read isbn
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: 0
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    [scanner setSymbology: ZBAR_EAN13
                   config: ZBAR_CFG_ENABLE
                       to: 1];
    [scanner setSymbology: ZBAR_ISBN10
                   config: ZBAR_CFG_ENABLE
                       to: 1];
    [scanner setSymbology: ZBAR_ISBN13
                   config: ZBAR_CFG_ENABLE
                       to: 1];
    
    [self presentModalViewController: reader animated: YES];
}

- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // get the results
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    
    // just grab the first barcode
    for(symbol in results)
        break;
    
    _tempISBN = symbol.data;
    [reader dismissModalViewControllerAnimated: YES];
    [self showProgressHUD];
}

- (void) showProgressHUD {
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:_HUD];		
    
    _HUD.labelText = @"询问豆瓣君中，请稍等……";
    _HUD.dimBackground = YES;
	_HUD.delegate = self;
	
	[_HUD showWhileExecuting:@selector(downloadBookInfo) onTarget:self withObject:nil animated:YES];
}

- (void) downloadBookInfo{
    _biDownloader = [[BookInfoDownloader alloc] initWithBookInstance:_bookToSave];
    _bookToSave = [_biDownloader getBookInfoByISBN: _tempISBN];    
//    _bookToSave = [_biDownloader getBookInfoByISBN:@"9780321321367"]; 
    
    // fail to get bookinfo
    if (((![_bookToSave.name length]) && (![_bookToSave.author length])) || Fail == _biDownloader.state){
        _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"failture.png"]];
        _HUD.mode = MBProgressHUDModeCustomView;
        _HUD.labelText = @"抱歉豆瓣君回应无能";
        _HUD.detailsLabelText = @"无此书信息或网络错误";
        sleep(1);
    }
    // success to get bookinf
    else {
        _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success.png"]];
        _HUD.mode = MBProgressHUDModeCustomView;
        _HUD.labelText = @"豆瓣君回话啦！";
    }
    sleep(0.5);
    [self refreshViews];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    NSLog(@"hud was hidden");
    [_HUD removeFromSuperview];
    _HUD = nil;
}

#pragma mark - button actions

- (IBAction)saveButtonTapped:(UIBarButtonItem *)sender {
    [_undoManager endUndoGrouping];
    
    //refresh timestamp which used to sort
    [_bookToSave setValue:[NSDate date] forKey:@"timeAdded"];

    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"确认放弃编辑？" 
                                                  message:@"所有未保存内容将丢失" 
                                                 delegate:self
                                        cancelButtonTitle:@"取消" 
                                        otherButtonTitles:@"确定",nil];  
    [alert show];  
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (1 == buttonIndex) {
        // undo all ops to _managedObjectContext here
        [_undoManager endUndoGrouping];
        [_undoManager undo];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - keyboard actions

// avoid keyboard from covering textfield
- (void)textFieldDidBeginEditing:(UITextField *)textField
{   
    CGRect frame = textField.frame;
    float heightOfKeyboard = 216.0;
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - heightOfKeyboard);

    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];               
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,self.view.frame.size.width,self.view.frame.size.height);               
        self.view.frame = rect;       
    }       
    [UIView commitAnimations];               
}

// close the keyboard
- (IBAction) textFieldDoneEditing:(UITextField *)textField
{
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];       
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);       
    self.view.frame = rect;
    [UIView commitAnimations];
    [textField resignFirstResponder];
}

// save instantly after editing
- (IBAction)textFieldEditingDidEnd:(UITextField *)sender {
    [_bookToSave setValue:_booknameText.text forKey:@"name"];
    [_bookToSave setValue:_authorText.text forKey:@"author"];
    [_bookToSave setValue:_isbnText.text forKey:@"isbn"];
}

#pragma mark - other methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
