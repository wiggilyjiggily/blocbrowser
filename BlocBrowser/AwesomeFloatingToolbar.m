//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Matthew Yang on 12/23/14.
//  Copyright (c) 2014 Tmrw, Inc. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSMutableArray *colors;
@property (nonatomic, strong) NSArray *labels;

@property (nonatomic, weak) UILabel *currentLabel;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@end

@implementation AwesomeFloatingToolbar

- (instancetype)initWithFourTitles:(NSArray *)titles {
    self = [super init];
    
    if (self) {
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
        
        for (NSString *currentTitle in self.currentTitles) {
            UILabel *label = [[UILabel alloc] init];
            label.userInteractionEnabled = NO;
            label.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:10];
            label.text = titleForThisLabel;
            label.backgroundColor = colorForThisLabel;
            label.textColor = [UIColor whiteColor];
            
            [labelsArray addObject:label];
        }
        self.labels = labelsArray;
        
        for (UILabel *thisLabel in self.labels) {
            [self addSubview:thisLabel];
        }
        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        [self addGestureRecognizer:self.tapGesture];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        
        self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longFired:)];
        [self addGestureRecognizer:self.longPress];
    }
    return self;
}

- (void)tapFired:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateRecognized) {
        
        CGPoint location = [sender locationInView:self];
        UIView *tappedView = [self hitTest:location withEvent:nil];
        
        if ([self.labels containsObject:tappedView]) {
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
            }
        }
    }
}

- (void)panFired:(UIPanGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [sender translationInView:self];
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [sender setTranslation:CGPointZero inView:self];
    }
}

- (void)pinchFired:(UIPinchGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        
        NSLog(@"New scale: %f", [sender scale]);
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithScale:)]) {
            [self.delegate floatingToolbar:self didTryToPinchWithScale:[sender scale]];
        }
        
        [sender setScale:[sender scale]];
    }
}

- (void)longFired:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateRecognized) {
        
        [self.colors exchangeObjectAtIndex:2 withObjectAtIndex:3];
        [self.colors exchangeObjectAtIndex:0 withObjectAtIndex:1];
        
        for (UILabel *label in self.labels) {
            NSUInteger currentLabelIndex = [self.labels indexOfObject:label];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentLabelIndex];
            label.backgroundColor = colorForThisLabel;
        }
    }
}

- (void)layoutSubviews {
    for (UILabel *thisLabel in self.labels) {
        NSUInteger currentLabelIndex = [self.labels indexOfObject:thisLabel];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        if (currentLabelIndex < 2) {
            labelY = 0;
        } else {
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        if (currentLabelIndex % 2 == 0) {
            labelX = 0;
        } else {
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    }
}

#pragma mark - Touch Handling

- (UILabel *)labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    return (UILabel *)subview;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UILabel *label = [self labelFromTouches:touches withEvent:event];
    
    self.currentLabel = label;
    self.currentLabel.alpha = 0.5;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UILabel *label = [self labelFromTouches:touches withEvent:event];
    
    if (self.currentLabel != label) {
        self.currentLabel.alpha = 1;
    } else {
        self.currentLabel.alpha = 0.5;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UILabel *label = [self labelFromTouches:touches withEvent:event];
    
    if (self.currentLabel == label) {
        NSLog(@"Label tapped: %@", self.currentLabel.text);
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
            [self.delegate floatingToolbar:self didSelectButtonWithTitle:self.currentLabel.text];
        }
    }
    self.currentLabel.alpha = 1;
    self.currentLabel = nil;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.currentLabel.alpha = 1;
    self.currentLabel = nil;
}

#pragma mark - Button Enabling

- (void)setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UILabel *label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.25;
    }
}

@end
