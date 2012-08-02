//
//  BookInfoDownloader.m
//  DoubanApiTest
//
//  Created by 罗 泽响 on 12-7-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BookInfoDownloader.h"

@interface BookInfoDownloader (Private)
- (BOOL) parseXML;
@end

@implementation BookInfoDownloader {
    Book *_book;
    NSString *_isbn;
    NSString *_tempAuthor;
    
    NSURL *_apiUrl;
    NSXMLParser *_xmlParser;
    NSString *_elementOfString;
}

@synthesize state = _state;

- (id)initWithBookInstance:(Book *)book {
    if(self = [super init])  
    { 
        _book = book;
        _state = Success;
    }  
    return self;  
} 

- (Book *) getBookInfo {
    // set isbn to isbn13
    if (10 == [_isbn length]) {
        _isbn = [@"978" stringByAppendingString:_isbn];
    }
    
    _apiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.douban.com/book/subject/isbn/%@", _isbn]];
    
    // _tempAuthor used to avoid repeat    
    _tempAuthor = [[NSString alloc] init];
    
    [self parseXML];
    
    [_book setValue:_isbn forKey:@"isbn"];
    [_book setValue:_tempAuthor forKey:@"author"];
    
    NSLog(@"%@",[[_book valueForKey:@"name"] description]);
    NSLog(@"%@",[[_book valueForKey:@"isbn"] description]);
   
    return _book;
}

- (Book *) getBookInfoByISBN:(NSString *)isbn {
    _isbn = isbn;
    return [self getBookInfo];
}

#pragma mark - NSXMLParserDelegates

- (BOOL) parseXML {    
    _xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:_apiUrl];
    if (_xmlParser) {
        [_xmlParser setDelegate:self];
        [_xmlParser setShouldResolveExternalEntities:YES];
        BOOL success = [_xmlParser parse];
        if (success) {
            _state = Success;
            NSLog(@"%@",@"successed");
        }
        else {
            _state = Fail;
            NSLog(@"%@",@"failed");
        }
        return success;
    }
    else {
        _state = Fail;
        NSLog(@"%@",@"NetworkProblem");        
        return NO;
    }
}

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
        if (![_tempAuthor length]) {
            _tempAuthor = _elementOfString;
        }
        else {
            _tempAuthor = [_tempAuthor stringByAppendingFormat:@", %@",_elementOfString];
        }
        NSLog(@"author %@",_elementOfString);   
    }
    NSLog(@"Found an element named: %@ with a value of: %@", elementName, _elementOfString);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if(_elementOfString == nil)
        _elementOfString = [[NSString alloc] init];
    _elementOfString = string;
}

@end
