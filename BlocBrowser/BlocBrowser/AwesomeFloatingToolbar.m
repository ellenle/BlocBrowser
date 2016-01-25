//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Ellen Thuy Le on 1/5/16.
//  Copyright (c) 2016 Ellen Thuy Le. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

@property (nonatomic,strong) NSArray *currentTitles;
@property (nonatomic,strong) NSArray *colors;
@property (nonatomic,strong) NSArray *buttons;
@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic) int labelIndex;

@end

@implementation AwesomeFloatingToolbar

- (instancetype)initWithFourTitles:(NSArray *)titles {
    //first, call the superclass (UIView)'s initializer, to make sure we do all that setup first
    self = [super init];
    
    if (self) {
        //save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
    
        NSMutableArray *buttonArray = [[NSMutableArray alloc] init];
        
        //make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [[UIButton alloc] init];
            button.userInteractionEnabled = NO;
            button.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; //0 to 3
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            [button setTitle:titleForThisLabel forState:UIControlStateNormal];
            button.backgroundColor = colorForThisLabel;
            button.titleLabel.textColor = [UIColor whiteColor];
            
            //TO DO - add tap handler?
            [button addTarget:self action:@selector(tapFired:) forControlEvents:UIControlEventTouchUpInside];
            
            [buttonArray addObject:button];
        }
        
        self.buttons = buttonArray;
        
        for (UILabel *thisLabel in self.buttons) {
            [self addSubview:thisLabel];
        }
        
        //#1 - 1 tells the gesture recognizers which methods to call when a tap is detected
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        
        //#2 -  tells the view (self) to route touch events through this gesture recognizer
        [self addGestureRecognizer:self.panGesture];
        [self addGestureRecognizer:self.pinchGesture];
        [self addGestureRecognizer:self.longPressGesture];
    }
    return self;
}

-(void) tapFired:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
        [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)sender.titleLabel).text];
    }
}

-(void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

-(void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
   
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didPinchToolbar:)]) {
        [self.delegate floatingToolbar:self didPinchToolbar:recognizer.scale];
    }
}

- (void)incrementLabelIndex {
    self.labelIndex++;
    if (self.labelIndex > 3) {
        self.labelIndex = 0;
    }
}

-(void) longPressFired:(UILongPressGestureRecognizer *) recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        for (UILabel *currentLabel in self.buttons) {
            [self incrementLabelIndex];
            currentLabel.backgroundColor = self.colors[self.labelIndex];
        }
        [self incrementLabelIndex];
    }
}

- (void)layoutSubviews {
    // set the frames for the 4 labels
    
    for (UIButton *thisButton in self.buttons) {
        NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        
        // adjust labelX and labelY for each label
        if (currentButtonIndex < 2) {
            // 0 or 1, so on top
            buttonY = 0;
        } else {
            // 2 or 3, so on bottom
            buttonY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentButtonIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
            // 0 or 2, so on the left
            buttonX = 0;
        } else {
            // 1 or 3, so on the right
            buttonX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    }
}

#pragma mark - Button Enabling

- (void)setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UILabel *label = [self.buttons objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.25;
    }
}

@end
