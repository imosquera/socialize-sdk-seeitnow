/*
 * SZPathBar.m
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

#import "SZPathBar.h"
#import <Socialize/NSNumber+Additions.h>

const NSString* kButton = @"kButton";
const NSString* kButtonHandler = @"kButtonHandler";

@interface SZPathBar()
@property(nonatomic, assign) UIViewController* controller;
@property(nonatomic, retain) NSMutableArray* buttonsWithHandlers;
@property(nonatomic, assign) BOOL liked;

@property(nonatomic, readonly) AwesomeMenuItem* profileButton;
@property(nonatomic, readonly) AwesomeMenuItem* commentsButton;
@property(nonatomic, readonly) AwesomeMenuItem* shareButton;
@property(nonatomic, readonly) AwesomeMenuItem* likeButton;


@end


@implementation SZPathBar
@synthesize entity =_entity;
@synthesize liked = _liked;
@synthesize controller = _controller;
@synthesize buttonsWithHandlers = _buttonsWithHandlers;
@synthesize menu = _menu;
@synthesize profileButton = _profileButton;
@synthesize commentsButton = _commentsButton;
@synthesize shareButton = _shareButton;
@synthesize likeButton = _likeButton;

-(id)initWithButtonsMask: (SZAvailableButtons)buttonsMask parentController: (UIViewController*) controller entity: (id<SZEntity>) entity
{
    self = [super init];
    if(self)
    {
        self.liked = NO;
        self.controller = controller;
        self.entity = entity;
                      
        self.buttonsWithHandlers = [NSMutableArray arrayWithCapacity:4];
        
        __block SZPathBar* weekSelf = self;
        if((buttonsMask & SZProfileButtonMask) == SZProfileButtonMask)
            [self addButton:self.profileButton handler:^(){
                [SZUserUtils showUserProfileInViewController:weekSelf.controller user:nil completion:nil];
            }];
        
        
        if((buttonsMask & SZCommentsButtonMask) == SZCommentsButtonMask)
            [self addButton:self.commentsButton handler:^(){
                [SZCommentUtils showCommentsListWithViewController:weekSelf.controller entity:weekSelf.entity completion:^(){
                    [weekSelf updateStatistic];
                }];
            }];

        
        if((buttonsMask & SZShareButtonMask) == SZShareButtonMask)
            [self addButton:self.shareButton handler:^(){
                [SZShareUtils showShareDialogWithViewController:weekSelf.controller entity:weekSelf.entity completion:^(NSArray *shares){
                    [weekSelf updateStatistic];
                } cancellation:nil];
            }];
        
        if((buttonsMask & SZLikeButtonMask) == SZLikeButtonMask)
        {
            [self addObserver:self forKeyPath:@"liked" options:NSKeyValueObservingOptionNew context:nil];
            
            [SZLikeUtils isLiked:self.entity 
                         success:^(BOOL isLiked){
                             self.liked = isLiked;
                         }
                         failure:^(NSError *error){
                             NSLog(@"Failed detect like: %@", [error localizedDescription]);
                             self.liked = NO;
                         }];
            
            
            [self addButton:self.likeButton handler:^(){
                if(weekSelf.liked == NO)
                {
                    [SZLikeUtils likeWithViewController:weekSelf.controller options:nil entity:weekSelf.entity
                                                success:^(id<SZLike> like){
                                                    weekSelf.liked = YES;
                                                    [weekSelf updateStatistic];
                                                }
                     
                                                failure:^(NSError *error) {
                                                    NSLog(@"Failed creating like: %@", [error localizedDescription]);
                                                }];
                }
                else
                {
                    [SZLikeUtils unlike:weekSelf.entity 
                                success:^(id<SZLike> like) {
                                    weekSelf.liked = NO;
                                    [weekSelf updateStatistic];
                                } 
                                failure:^(NSError *error) {
                                    NSLog(@"Failed deleting like: %@", [error localizedDescription]);
                                }];
                }

            }];
        }       
    }

    return self;
}

-(void) addButton:(AwesomeMenuItem*) button handler:(void(^)()) handler
{
    [self.buttonsWithHandlers addObject:[NSDictionary dictionaryWithObjectsAndKeys:button, kButton, [[handler copy] autorelease], kButtonHandler, nil]];
}

-(void)dealloc
{
    NSLog(@"dealloc bar");
    
    if(_likeButton)
        [self removeObserver:self forKeyPath:@"liked"];
    
    [_menu release];
    [_profileButton release];
    [_commentsButton release];
    [_shareButton release];
    [_likeButton release];
    [_entity release];
    self.buttonsWithHandlers = nil;
    self.controller = nil;
    
    [super dealloc];
}

-(AwesomeMenuItem*)profileButton
{
    if(!_profileButton)
    {
        UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
        UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
        
        _profileButton = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                highlightedImage:storyMenuItemImagePressed 
                                                    ContentImage:[UIImage imageNamed:@"socialize-icon-profile-active.png"] 
                                         highlightedContentImage:nil];
    }
    return _profileButton;
}

-(AwesomeMenuItem*)commentsButton
{
    if(!_commentsButton)
    {
       
        NSString* imageName = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ?  @"button-comment.png" : @"button-comment-iphone.png";
        
        _commentsButton = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                highlightedImage:[UIImage imageNamed:imageName]
                                                    ContentImage:nil
                                         highlightedContentImage:nil];
              
    }
    return _commentsButton;
}

-(AwesomeMenuItem*)shareButton
{
    if(!_shareButton)
    {
        
        NSString* imageName = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ?  @"button-bar-share.png" : @"button-bar-share-iphone.png";
        
        _shareButton = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                highlightedImage:[UIImage imageNamed:imageName] 
                                                    ContentImage:nil
                                         highlightedContentImage:nil];
    }
    return _shareButton;
}

-(AwesomeMenuItem*)likeButton
{
    if(!_likeButton)
    {
       
        NSString* imageName = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ?  @"button-like.png" : @"button-like-iphone.png";
        
        _likeButton = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                highlightedImage:[UIImage imageNamed:imageName]
                                                    ContentImage:nil
                                         highlightedContentImage:nil];
               
    }
    return _likeButton;
}

-(AwesomeMenu*)menu
{
    if(!_menu)
    {
        _menu = [[AwesomeMenu alloc]initWithFrame:self.controller.view.bounds menus:[self.buttonsWithHandlers valueForKeyPath:@"@unionOfObjects.kButton"]];
        _menu.delegate = self;
        
        NSString* imageName = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ?  @"button-socialize.png" : @"button-socialize-iphone.png";
        _menu.image = [UIImage imageNamed:imageName];
        _menu.highlightedImage = nil;
        _menu.contentImage = nil;
        _menu.highlightedImage = nil;
        _menu.menuWholeAngle = 0;
        _menu.endRadius += 100;
    }
    return _menu;
}

-(void)setEntity:(id<SocializeEntity>)entity
{
    if(entity == nil)
    {
        [_entity release]; _entity = nil;
        return;
    }
    
    if(_entity != entity)
    {
        [_entity release]; _entity = [entity retain];
        
        if([entity isFromServer])
        {
            [self configureForNewServerEntity];
        }
        else
        {
            [SZEntityUtils addEntity:entity success:^(id<SZEntity> serverEntity)
            {
                [_entity release]; _entity = [serverEntity retain];
                [self configureForNewServerEntity];
            }
            failure:^(NSError *error) {
                SZEmitUIError(self, error);
            }];
        }
    }
}

#pragma Awesome menu

-(void) updateStatistic
{
    [SZEntityUtils getEntityWithKey:self.entity.key success:^(id<SZEntity> entity)
    {
        self.entity = entity;
        [self updateCountBobble];

    } failure:nil];
}

- (void)AwesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    void (^handler)() = [[self.buttonsWithHandlers objectAtIndex:idx]objectForKey:kButtonHandler];
    handler();
}

- (void)AwesomeMenu:(AwesomeMenu *)menu item:(AwesomeMenuItem*) item onIndex:(NSInteger)i
{
    const int count = menu.menusArray.count;
    item.startPoint = menu.startPoint;
    CGPoint endPoint = CGPointMake(menu.startPoint.x,  menu.startPoint.y - (i + 1)* menu.endRadius / (count + 1));
    item.endPoint = endPoint;
    item.nearPoint = endPoint;
    item.farPoint = endPoint;
    item.center = item.startPoint;
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"liked"] )
    {
        if(self.liked)
        {
            NSString* imageName = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ?  @"button-liked.png" : @"button-liked-iphone.png";
            self.likeButton.image = [UIImage imageNamed:imageName];
            self.likeButton.highlightedImage = [UIImage imageNamed:imageName];
        }
        else
        {
            NSString* imageName = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ?  @"button-like.png" : @"button-like-iphone.png";
            self.likeButton.image = [UIImage imageNamed:imageName];
            self.likeButton.highlightedImage = [UIImage imageNamed:imageName];
        }
    }
}

-(void)updateCountBobble
{
    self.menu.badge.badgeText = [NSNumber formatMyNumber:[NSNumber numberWithInteger:self.entity.likes + self.entity.comments + self.entity.shares] ceiling:[NSNumber numberWithInt:1000]];
    self.menu.badge.hidden = NO;
    
    self.likeButton.badge.badgeText = [NSNumber formatMyNumber:[NSNumber numberWithInteger:self.entity.likes] ceiling:[NSNumber numberWithInt:1000]];
    self.commentsButton.badge.badgeText = [NSNumber formatMyNumber:[NSNumber numberWithInteger:self.entity.comments] ceiling:[NSNumber numberWithInt:1000]];
    self.shareButton.badge.badgeText = [NSNumber formatMyNumber:[NSNumber numberWithInteger:self.entity.shares] ceiling:[NSNumber numberWithInt:1000]];
}

-(void) configureForNewServerEntity
{    
    if(_likeButton)
    {
        [SZLikeUtils isLiked:_entity
                     success:^(BOOL isLiked){
                         self.liked = isLiked;
                     }
                     failure:^(NSError *error){
                         NSLog(@"Failed detect like: %@", [error localizedDescription]);
                         self.liked = NO;
                     }];
    }
    
    [SZViewUtils viewEntity:self.entity success:^(id<SocializeView> view) {
        NSLog(@"View created: %d", [view objectID]);
    } failure:^(NSError *error) {
        NSLog(@"Failed recording view: %@", [error localizedDescription]);
    }];
    
    [self updateCountBobble];
}

@end
