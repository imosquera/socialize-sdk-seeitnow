/*
 * SZPathBar.h
 * SSZ_alpha
 *
 * Created on 8/7/12.
 * 
 * Copyright (c) 2012 Socialize, Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import "AwesomeMenu.h"
#import <Socialize/Socialize.h>

extern const NSString* kButton;
extern const NSString* kButtonHandler;

enum {
    SZNonButtons             = 0,
    SZProfileButtonMask      = 1 << 0,
    SZCommentsButtonMask     = 1 << 1,
    SZShareButtonMask        = 1 << 2,
    SZLikeButtonMask         = 1 << 3
};

typedef NSUInteger SZAvailableButtons;

@interface SZPathBar : NSObject<AwesomeMenuDelegate> {
}

-(id)initWithButtonsMask: (SZAvailableButtons)buttonsMask parentController: (UIViewController*) controller entity: (id<SZEntity>) entity;
-(void) addButton:(AwesomeMenuItem*) button handler:(void(^)()) handler;

@property(nonatomic, readonly) AwesomeMenu* menu;
@property(nonatomic, retain) id<SZEntity> entity;

@end