//
//  InfoEditViewController.h
//  MyLibrary
//
//  Created by 罗 泽响 on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarReaderViewController.h"
#import "Book.h"
#import "MBProgressHUD.h"

@interface EditBookInfoViewController : UIViewController <ZBarReaderDelegate, MBProgressHUDDelegate, UIAlertViewDelegate, UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *isbnText;
@property (strong, nonatomic) IBOutlet UITextField *booknameText;
@property (strong, nonatomic) IBOutlet UITextField *authorText;
@property (strong, nonatomic) IBOutlet UITextField *stateText;
@property (strong, nonatomic) IBOutlet UITextField *positionText;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPickerView *statePicker;
@property (strong, nonatomic) IBOutlet UIToolbar *doneToolBar;

@property (strong, nonatomic) Book *bookToSave;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)stateDoneButtonTapped:(UIBarButtonItem *)sender;
- (IBAction) scanButtonTapped:(UIBarButtonItem *)sender;
- (IBAction) saveButtonTapped:(UIBarButtonItem *)sender;
- (IBAction) cancelButtonTapped:(UIBarButtonItem *)sender;
- (IBAction) textFieldDoneEditing:(UITextField *)sender;
- (IBAction) textFieldEditingDidEnd:(UITextField *)sender;

-(void)setBookToSave:(Book *)bookToSave;

@end
