//
//  AwesomeMenuItem.m
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.
//

#import "AwesomeMenuItem.h"

static inline CGRect ScaleRect(CGRect rect, float n) {return CGRectMake((rect.size.width - rect.size.width * n)/ 2, (rect.size.height - rect.size.height * n) / 2, rect.size.width * n, rect.size.height * n);}
@implementation AwesomeMenuItem

@synthesize contentImageView = _contentImageView;

@synthesize startPoint = _startPoint;
@synthesize endPoint = _endPoint;
@synthesize nearPoint = _nearPoint;
@synthesize farPoint = _farPoint;
@synthesize delegate  = _delegate;
@synthesize badge;

#pragma mark - initialization & cleaning up
- (id)initWithImage:(UIImage *)img 
   highlightedImage:(UIImage *)himg
       ContentImage:(UIImage *)cimg
highlightedContentImage:(UIImage *)hcimg;
{
    if (self = [super init]) 
    {
        self.image = img;
        self.highlightedImage = himg;
        self.userInteractionEnabled = YES;
        _contentImageView = [[UIImageView alloc] initWithImage:cimg];
        _contentImageView.highlightedImage = hcimg;
        [self addSubview:_contentImageView];
        [self addBadgeView];
        
        self.bounds = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    }
    return self;
}

-(void)addBadgeView
{
    JSBadgeView *badgeView = [[[JSBadgeView alloc] initWithParentView:self alignment:JSBadgeViewAlignmentTopCenter] autorelease];
    badgeView.badgeText = [NSString stringWithFormat:@"%d", 0];
    badgeView.badgePositionAdjustment = CGPointMake(13, 5);
    badgeView.alpha = 0.0;
    self.badge = badgeView;
}

- (id)initWithImage:(UIImage *)img
   highlightedImage:(UIImage *)himg
       ContentView:(UIView *)cview
{
    if (self = [super init]) 
    {
        self.image = img;
        self.highlightedImage = himg;
        self.userInteractionEnabled = YES;
        _viewTest = [cview retain];
        [self addSubview:cview];
        [self addBadgeView];
        
        self.bounds = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    }
    return self;
}

- (void)dealloc
{
    [_contentImageView release];
    [_viewTest release];
    self.badge = nil;
    
    [super dealloc];
}
#pragma mark - UIView's methods
- (void)layoutSubviews
{
    [super layoutSubviews];
       
    float width = _contentImageView.image.size.width;
    float height = _contentImageView.image.size.height;
    _contentImageView.frame = CGRectMake(self.bounds.size.width/2 - width/2, self.bounds.size.height/2 - height/2, width, height);
    
    width = _viewTest.frame.size.width;
    height = _viewTest.frame.size.height;
    _viewTest.frame = CGRectMake(self.bounds.size.width/2 - width/2, self.bounds.size.height/2 - height/2, width, height);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = YES;
    if ([_delegate respondsToSelector:@selector(AwesomeMenuItemTouchesBegan:)])
    {
       [_delegate AwesomeMenuItemTouchesBegan:self];
    }
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // if move out of 2x rect, cancel highlighted.
    CGPoint location = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(ScaleRect(self.bounds, 2.0f), location))
    {
        self.highlighted = NO;
    }
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
    // if stop in the area of 2x rect, response to the touches event.
    CGPoint location = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(ScaleRect(self.bounds, 2.0f), location))
    {
        if ([_delegate respondsToSelector:@selector(AwesomeMenuItemTouchesEnd:)])
        {
            [_delegate AwesomeMenuItemTouchesEnd:self];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}

#pragma mark - instant methods
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [_contentImageView setHighlighted:highlighted];
}


@end
