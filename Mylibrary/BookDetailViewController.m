//
//  DetailViewController.m
//  StoryboardTutorial
//
//  Created by 罗 泽响 on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BookDetailViewController.h"
#import "EditBookInfoViewController.h"

@interface BookDetailViewController (Private)
- (void) refreshViews;
@end

@implementation BookDetailViewController 

@synthesize booknameLabel = _booknameLabel;
@synthesize authorLabel = _authorLabel;
@synthesize isbnLabel = _isbnLabel;
@synthesize stateLabel = _stateLabel;
@synthesize positionLabel = _positionLabel;
@synthesize backGestureRecognizer = _backGestureRecognizer;

@synthesize bookToDisplay = _bookToDisplay;
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
}

- (void) viewWillAppear:(BOOL)animated {
    [self refreshViews];
}

- (void)viewDidUnload
{
    [self setBackGestureRecognizer:nil];
    [self setBooknameLabel:nil];
    [self setAuthorLabel:nil];
    [self setIsbnLabel:nil];
    [self setStateLabel:nil];
    [self setPositionLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) refreshViews {
    _booknameLabel.text = [[_bookToDisplay valueForKey:@"name"] description];
    _authorLabel.text = [[_bookToDisplay valueForKey:@"author"] description];
    _isbnLabel.text = [[_bookToDisplay valueForKey:@"isbn"] description];
    _stateLabel.text = [[_bookToDisplay valueForKey:@"state"] description]; 
    _positionLabel.text = [[_bookToDisplay valueForKey:@"position"] description]; 
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EditBookInfoViewController *editBookInfoViewController = [segue destinationViewController];
    editBookInfoViewController.managedObjectContext = _managedObjectContext;
    editBookInfoViewController.bookToSave = _bookToDisplay;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)backGestureDetected:(UISwipeGestureRecognizer *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
