//
//  BookInfoDownloader.h
//  DoubanApiTest
//
//  Created by 罗 泽响 on 12-7-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReturnState.h"
#import "Book.h"

@interface BookInfoDownloader : NSObject <NSXMLParserDelegate>

@property (nonatomic) ReturnState state;

- (id)initWithBookInstance:(Book *)book;
- (Book *) getBookInfoByISBN:(NSString *)isbn;
- (Book *) getBookInfo;
@end
