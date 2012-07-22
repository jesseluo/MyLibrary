//
//  BookInfoDownloader.m
//  DoubanApiTest
//
//  Created by 罗 泽响 on 12-7-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BookInfoDownloader.h"
#import "ASIHTTPRequest.h"

@implementation BookInfoDownloader {
    Book *_book;
    NSString *_isbn;
    
    NSURL *_apiUrl;
    NSXMLParser *_xmlParser;
    NSString *_elementOfString;
}

- (id)initWithBookInstance:(Book *)book {
    if(self = [super init])  
    { 
        _book = book;
    }  
    return self;  
} 

- (Book *) getBookInfo {
    // set isbn to isbn13
    if (10 == [_isbn length]) {
        _isbn = [@"978" stringByAppendingString:_isbn];
    }
    [_book setValue:_isbn forKey:@"isbn"];
    
    _apiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.douban.com/book/subject/isbn/%@", _isbn]];
    
    // start an Asynchronous request, use weakRequest to prevent retain cycle
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL :_apiUrl];
    ASIHTTPRequest __weak *weakRequest = request;
    
    // resquest successed
    [request setCompletionBlock :^{
        NSData *responseData = [weakRequest responseData];
        _xmlParser = [[NSXMLParser alloc] initWithData:responseData];
        [_xmlParser setDelegate:self];
        [_xmlParser setShouldResolveExternalEntities:YES];
        [_xmlParser parse];
    }];
    
    // resquest failed
    [request setFailedBlock :^{
        NSError *error = [weakRequest error];
        NSLog ( @"error:%@" ,[error userInfo]);
    }];
    
    [request startAsynchronous];

    NSLog(@"%@",[[_book valueForKey:@"name"] description]);
    NSLog(@"%@",[[_book valueForKey:@"isbn"] description]);

    return _book;
}

- (Book *) getBookInfoByISBN:(NSString *)isbn {
    _isbn = isbn;
    return [self getBookInfo];
}

#pragma mark - NSXMLParserDelegates

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
//    NSLog(@"Started Element %@", elementName);
    _elementOfString = [[NSString alloc] init];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString: @"title"]) {
        [_book setValue:_elementOfString forKey:@"name"];
        NSLog(@"bookname %@",_elementOfString);
        NSLog(@"%@",_book.name);
    }
    
    if ([elementName isEqualToString: @"name"]) {
        if (![_book.author length]) {
            [_book setValue:_elementOfString forKey:@"author"];
        }
        else {
            [_book setValue:[_book.author stringByAppendingFormat:@", %@",_elementOfString] forKey:@"author"];
        }
        NSLog(@"author %@",_elementOfString);
        NSLog(@"%@",_book.author);    
    }
    NSLog(@"Found an element named: %@ with a value of: %@", elementName, _elementOfString);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if(_elementOfString == nil)
        _elementOfString = [[NSString alloc] init];
    _elementOfString = string;
}

@end
