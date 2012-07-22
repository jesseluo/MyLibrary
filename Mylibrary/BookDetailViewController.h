//
//  DetailViewController.h
//  StoryboardTutorial
//
//  Created by 罗 泽响 on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@interface BookDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *booknameLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *isbnLabel;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *backGestureRecognizer;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Book *bookToDisplay;

- (IBAction)backGestureDetected:(UISwipeGestureRecognizer *)sender;

@end
