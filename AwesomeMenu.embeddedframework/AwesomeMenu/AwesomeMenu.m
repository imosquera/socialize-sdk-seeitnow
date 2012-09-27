//
//  AwesomeMenu.m
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.
//

#import "AwesomeMenu.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kAwesomeMenuDefaultNearRadius = 110.0f;
static CGFloat const kAwesomeMenuDefaultEndRadius = 120.0f;
static CGFloat const kAwesomeMenuDefaultFarRadius = 140.0f;
static CGFloat const kAwesomeMenuDefaultStartPointX = 160.0;
static CGFloat const kAwesomeMenuDefaultStartPointY = 240.0;
static CGFloat const kAwesomeMenuDefaultTimeOffset = 0.036f;
static CGFloat const kAwesomeMenuDefaultRotateAngle = 0.0;
static CGFloat const kAwesomeMenuDefaultMenuWholeAngle = M_PI * 2;
static CGFloat const kAwesomeMenuDefaultExpandRotation = M_PI;
static CGFloat const kAwesomeMenuDefaultCloseRotation = M_PI * 2;

static CGPoint RotateCGPointAroundCenter(CGPoint point, CGPoint center, float angle)
{
    CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), translation);
    return CGPointApplyAffineTransform(point, transformGroup);    
}

@interface AwesomeMenu ()
- (void)_expand;
- (void)_close;
- (void)_setMenu;
- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p;
- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p;
- (void)_defaultItemPosition: (AwesomeMenuItem *)item itemIndex: (int) i;

@property(nonatomic, retain)UIView* badgePlaceHolder;
@end

@implementation AwesomeMenu

@synthesize nearRadius, endRadius, farRadius, timeOffset, rotateAngle, menuWholeAngle, startPoint, expandRotation, closeRotation;
@synthesize expanding = _expanding;
@synthesize delegate = _delegate;
@synthesize menusArray = _menusArray;
@synthesize mainButton  = _addButton;
@synthesize badge;
@synthesize badgePlaceHolder;

#pragma mark - initialization & cleaning up
- (id)initWithFrame:(CGRect)frame menus:(NSArray *)aMenusArray
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
		
		self.nearRadius = kAwesomeMenuDefaultNearRadius;
		self.endRadius = kAwesomeMenuDefaultEndRadius;
		self.farRadius = kAwesomeMenuDefaultFarRadius;
		self.timeOffset = kAwesomeMenuDefaultTimeOffset;
		self.rotateAngle = kAwesomeMenuDefaultRotateAngle;
		self.menuWholeAngle = kAwesomeMenuDefaultMenuWholeAngle;
		self.startPoint = CGPointMake(kAwesomeMenuDefaultStartPointX, kAwesomeMenuDefaultStartPointY);
        self.expandRotation = kAwesomeMenuDefaultExpandRotation;
        self.closeRotation = kAwesomeMenuDefaultCloseRotation;
        
        self.menusArray = aMenusArray;
                
        NSString* coverName = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ?  @"button-socialize.png" : @"button-socialize-iPhone.png";
        NSString* imageName = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ?  @"button-socialize-logo.png" : @"button-socialize-logo-iPhone.png";
        
        // add the main Button.
        _addButton = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:coverName]
                                       highlightedImage:[UIImage imageNamed:coverName]
                                           ContentImage:[UIImage imageNamed:imageName]
                                highlightedContentImage:[UIImage imageNamed:imageName]];
        

        _addButton.delegate = self;
        _addButton.center = self.startPoint;
        
        [self addSubview:_addButton];
       
        self.badgePlaceHolder = [[[UIView alloc] initWithFrame:_addButton.frame] autorelease];
        self.badgePlaceHolder.backgroundColor = [UIColor clearColor];
        
        self.badge = [[[JSBadgeView alloc] initWithParentView:self.badgePlaceHolder alignment:JSBadgeViewAlignmentTopRight] autorelease];
        self.badge.badgeText = [NSString stringWithFormat:@"%d", 0];
        CGPoint badgePositionAdjustment = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? CGPointMake(-10, 8) : CGPointMake(-7, 4);
        self.badge.badgePositionAdjustment = badgePositionAdjustment;
        
        [self addSubview:self.badgePlaceHolder];
        
    }
    return self;
}

- (void)dealloc
{
    [_addButton release];
    [_menusArray release];
    self.badge = nil;
    self.badgePlaceHolder = nil;
    
    [super dealloc];
}

#pragma mark - getters & setters

- (void)setStartPoint:(CGPoint)aPoint
{
    startPoint = aPoint;
    _addButton.center = aPoint;
    self.badgePlaceHolder.center = self.startPoint;
}

#pragma mark - images

- (void)setImage:(UIImage *)image {
	_addButton.image = image;
}

- (UIImage*)image {
	return _addButton.image;
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
	_addButton.highlightedImage = highlightedImage;
}

- (UIImage*)highlightedImage {
	return _addButton.highlightedImage;
}


- (void)setContentImage:(UIImage *)contentImage {
	_addButton.contentImageView.image = contentImage;
}

- (UIImage*)contentImage {
	return _addButton.contentImageView.image;
}

- (void)setHighlightedContentImage:(UIImage *)highlightedContentImage {
	_addButton.contentImageView.highlightedImage = highlightedContentImage;
}

- (UIImage*)highlightedContentImage {
	return _addButton.contentImageView.highlightedImage;
}


                               
#pragma mark - UIView's methods
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // if the menu is animating, prevent touches
    if (_isAnimating) 
    {
        return NO;
    }
    // if the menu state is expanding, everywhere can be touch
    // otherwise, only the add button are can be touch
    if (YES == _expanding) 
    {
        return YES;
    }
    else
    {
        return CGRectContainsPoint(_addButton.frame, point);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.expanding = !self.isExpanding;
}

#pragma mark - AwesomeMenuItem delegates
- (void)AwesomeMenuItemTouchesBegan:(AwesomeMenuItem *)item
{
    if (item == _addButton) 
    {
        self.expanding = !self.isExpanding;
    }
}
- (void)AwesomeMenuItemTouchesEnd:(AwesomeMenuItem *)item
{
    // exclude the "add" button
    if (item == _addButton) 
    {
        return;
    }
    // blowup the selected menu button
    CAAnimationGroup *blowup = [self _blowupAnimationAtPoint:item.center];
    [item.layer addAnimation:blowup forKey:@"blowup"];
    item.center = item.startPoint;
    
    // shrink other menu buttons
    for (int i = 0; i < [_menusArray count]; i ++)
    {
        AwesomeMenuItem *otherItem = [_menusArray objectAtIndex:i];
        CAAnimationGroup *shrink = [self _shrinkAnimationAtPoint:otherItem.center];
        if (otherItem.tag == item.tag) {
            continue;
        }
        [otherItem.layer addAnimation:shrink forKey:@"shrink"];

        otherItem.center = otherItem.startPoint;
    }
    _expanding = NO;
    
    // rotate "add" button
    float angle = self.isExpanding ? M_PI_4 : 0.0f;
    
    [UIView animateWithDuration:0.2f animations:^{
        _addButton.transform = CGAffineTransformMakeRotation(angle);
        self.badge.alpha = (angle == 0.0f) ? 1.0f : 0.0f;
    }];
    
    if ([_delegate respondsToSelector:@selector(AwesomeMenu:didSelectIndex:)])
    {
        [_delegate AwesomeMenu:self didSelectIndex:item.tag - 1000];
    }
}

#pragma mark - instant methods
- (void)setMenusArray:(NSArray *)aMenusArray
{	
    if (aMenusArray == _menusArray)
    {
        return;
    }
    [_menusArray release];
    _menusArray = [aMenusArray copy];
    
    
    // clean subviews
    for (UIView *v in self.subviews) 
    {
        if (v.tag >= 1000) 
        {
            [v removeFromSuperview];
        }
    }
}

- (void)_defaultItemPosition: (AwesomeMenuItem *)item itemIndex: (int) i
{
    const int count = _menusArray.count;
    item.startPoint = startPoint;
    CGPoint endPoint = CGPointMake(startPoint.x + endRadius * sinf(i * menuWholeAngle / count), startPoint.y - endRadius * cosf(i * menuWholeAngle / count));
    item.endPoint = RotateCGPointAroundCenter(endPoint, startPoint, rotateAngle);
    CGPoint nearPoint = CGPointMake(startPoint.x + nearRadius * sinf(i * menuWholeAngle / count), startPoint.y - nearRadius * cosf(i * menuWholeAngle / count));
    item.nearPoint = RotateCGPointAroundCenter(nearPoint, startPoint, rotateAngle);
    CGPoint farPoint = CGPointMake(startPoint.x + farRadius * sinf(i * menuWholeAngle / count), startPoint.y - farRadius * cosf(i * menuWholeAngle / count));
    item.farPoint = RotateCGPointAroundCenter(farPoint, startPoint, rotateAngle);
    item.center = item.startPoint;
}

- (void)_setMenu {
	int count = [_menusArray count];
    for (int i = 0; i < count; i ++)
    {
        AwesomeMenuItem *item = [_menusArray objectAtIndex:i];
        item.tag = 1000 + i;

        if ([_delegate respondsToSelector:@selector(AwesomeMenu:item:onIndex:)])
            [_delegate AwesomeMenu:self item:item onIndex:i];
        else
            [self _defaultItemPosition: item itemIndex:i];
        
        item.delegate = self;
        item.hidden = YES;
		[self insertSubview:item belowSubview:_addButton];
    }
}

- (BOOL)isExpanding
{
    return _expanding;
}

- (void)setExpanding:(BOOL)expanding
{
	if (expanding) {
		[self _setMenu];
	}
	
    _expanding = expanding;    
    
    // rotate add button
    float angle = self.isExpanding ? M_PI_4 : 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        _addButton.transform = CGAffineTransformMakeRotation(angle);
        self.badge.alpha = (angle == 0.0f) ? 1.0f : 0.0f;
    }];
    
    // expand or close animation
    if (!_timer) 
    {
        _flag = self.isExpanding ? 0 : ([_menusArray count] - 1);
        SEL selector = self.isExpanding ? @selector(_expand) : @selector(_close);

        // Adding timer to runloop to make sure UI event won't block the timer from firing
        _timer = [[NSTimer timerWithTimeInterval:timeOffset target:self selector:selector userInfo:nil repeats:YES] retain];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        _isAnimating = YES;
    }
}

#pragma mark - private methods
- (void)_expand
{
	
    if (_flag == [_menusArray count])
    {
        _isAnimating = NO;
        [_timer invalidate];
        [_timer release];
        _timer = nil;
        return;
    }
    
    int tag = 1000 + _flag;
    AwesomeMenuItem *item = (AwesomeMenuItem *)[self viewWithTag:tag];
    [item.layer removeAllAnimations];
    item.hidden = NO;
   
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:expandRotation],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = 0.5f;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.3], 
                                [NSNumber numberWithFloat:.4], nil]; 
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.5f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.nearPoint.x, item.nearPoint.y); 
    CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
           
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    animationgroup.duration = 0.5f;
    animationgroup.removedOnCompletion = NO;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [item.layer addAnimation:animationgroup forKey:@"Expand"];
    item.center = item.endPoint;
    
    [UIView animateWithDuration:0.2f animations:^{
        item.badge.alpha = 1.0f;
    }];
   
    _flag ++;
}

- (void)_close
{
    if (_flag == -1)
    {
        _isAnimating = NO;
        [_timer invalidate];
        [_timer release];
        _timer = nil;
               
        return;
    }
    
    int tag = 1000 + _flag;
    AwesomeMenuItem *item = (AwesomeMenuItem *)[self viewWithTag:tag];
    [item.layer removeAllAnimations];
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:closeRotation],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = 0.5f;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.0], 
                                [NSNumber numberWithFloat:.4],
                                [NSNumber numberWithFloat:.5], nil]; 
        
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.5f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.startPoint.x, item.startPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    opacityAnimation.duration = 0.1f;
    [opacityAnimation setBeginTime:0.4f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.5f;
    animationgroup.removedOnCompletion = NO;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [item.layer addAnimation:animationgroup forKey:@"Close"];
    
    item.center = item.startPoint;
    
    [UIView animateWithDuration:0.2f animations:^{
        item.badge.alpha = 0.0f;
    }];

    _flag --;
}

- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil]; 
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.removedOnCompletion = NO;
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.3f;
    animationgroup.fillMode = kCAFillModeForwards;

    return animationgroup;
}

- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil]; 
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.01, .01, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.removedOnCompletion = NO;
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.3f;
    animationgroup.fillMode = kCAFillModeForwards;
    
    return animationgroup;
}


@end
