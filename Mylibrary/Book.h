//
//  Book.h
//  Mylibrary
//
//  Created by 罗 泽响 on 12-7-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Book : NSManagedObject

@property (nonatomic, retain) NSDate * timeAdded;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * isbn;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSData * coverImage;

@end
