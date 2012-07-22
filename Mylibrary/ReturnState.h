//
//  ReturnState.h
//  Mylibrary
//
//  Created by 罗 泽响 on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef Mylibrary_ReturnState_h
#define Mylibrary_ReturnState_h

#import <Foundation/Foundation.h>

enum ReturnState {
    NetworkProblem,
    XMLParseFailed,
    Fail,
    Success
};

typedef enum ReturnState ReturnState;


#endif
