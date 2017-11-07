//
//  AppTextField.m
//  TFDemoApp
//
//  Created by Abhishek Chandani on 19/05/16.
//  Copyright © 2016 Abhishek. All rights reserved.
//

#import "ACFloatingTextField.h"

#define HEXC(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "ACFloatingTextField.h"

@implementation ACFloatingTextField

#pragma mark :- Drawing Methods
- (void)drawRect:(CGRect)rect {
    [self updateTextField:CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(rect), CGRectGetHeight(rect))];
}

#pragma mark :- Loading From NIB
- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialization];
}

#pragma mark :- Initialization Methods
- (instancetype) init {
    if (self) {
        self = [super init];
        [self initialization];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self) {
        self = [super initWithFrame:frame];
        [self initialization];
    }
    return self;
}

#pragma mark :- Drawing Text Rect
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(2, 2, bounds.size.width - self.alignRight, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    if (self.clearButtonMode == UITextFieldViewModeNever) {
        return CGRectMake(2, 2, bounds.size.width - self.alignRight, bounds.size.height);
    } else {
        return CGRectMake(2, 2, bounds.size.width - self.alignRight - 24, bounds.size.height);
    }
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGRect originalRect = [super clearButtonRectForBounds:bounds];
    return CGRectOffset(originalRect, - self.alignRight, 0);
}



#pragma mark  Override Set text
- (void)setShowError:(BOOL)showError {
    showingError = showError;
    if (showingError) {
        [self beginShowError];
    } else {
        [self beginHideError];
    }
}

- (BOOL)showError {
    return showingError;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    if (text) {
        [self floatTheLabel];
    }
    if (showingError) {
        [self hideErrorPlaceHolder];
    }
}

#pragma mark  Set Placeholder Text On Label
-(void)setPlaceholder:(NSString *)placeholder {
    [super setPlaceholder:placeholder];
    if (![placeholder isEqualToString:@""]) {
        self.labelPlaceholder.text = placeholder;
    }
    
}
- (void)setTextFieldPlaceholderText:(NSString *)placeholderText {
    [self setPlaceholder:placeholderText];
}

#pragma mark  Set Error Text On Label
-(void)setErrorText:(NSString *)errorText {
    _errorText = errorText;
    self.labelErrorPlaceholder.text = errorText;
}

- (void)initialization {
    self.disableShakeWithError = YES;
    self.clipsToBounds = NO;
    //VARIABLE INITIALIZATIONS
    
    //1. Placeholder Color.
    if (_placeHolderColor == nil){
        _placeHolderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.38];
    }
    
    //2. Placeholder Color When Selected.
    if (_selectedPlaceHolderColor==nil) {
        _selectedPlaceHolderColor = HEXC(0x1BA8FF);
    }
    
    //3. Bottom line Color.
    if (_lineColor == nil) {
        _lineColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12];
    }
    
    //4. Bottom line Color When Selected.
    if (_selectedLineColor == nil) {
        _selectedLineColor = HEXC(0x1BA8FF);
    }
    
    
    //5. Bottom line error Color.
    if (_errorLineColor==nil) {
        _errorLineColor = [UIColor redColor];
    }
    
    //6. Bottom place Color When show error.
    if (_errorTextColor==nil) {
        _errorTextColor = [UIColor redColor];
    }
    
    /// Adding Bottom Line View.
    [self addBottomLineView];
    
    /// Adding Placeholder Label.
    [self addPlaceholderLabel];
    
    [self setValue:self.placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
    
    /// Placeholder Label Configuration.
    if (![self.text isEqualToString:@""]) {
        [self floatTheLabel];
    }
    
}

#pragma mark :- Private Methods
- (void)addBottomLineView{
    if (bottomLineView.superview != nil) {
        CGRect bottomLineFrame = bottomLineView.frame;
        bottomLineFrame.origin.x = 2;
        bottomLineFrame.size.width = self.frame.size.width - 2;
        bottomLineView.frame = bottomLineFrame;
        return;
    }
    [bottomLineView removeFromSuperview];
    
    bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(2, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame) -2, 1)];
    bottomLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bottomLineView.backgroundColor = _lineColor;
    [self addSubview:bottomLineView];
}

- (void)addPlaceholderLabel {
    if (![self.placeholder isEqualToString:@""] && self.placeholder!=nil) {
        _labelPlaceholder.text = self.placeholder;
    }
    if (self.labelPlaceholder.superview != nil){
        CGRect labelFrame = self.labelPlaceholder.frame;
        labelFrame.origin.x = 2;
        labelFrame.origin.y = -4;
        labelFrame.size.width = self.frame.size.width;
        self.labelPlaceholder.frame = labelFrame;
        return;
    }
    
    [_labelPlaceholder removeFromSuperview];
    NSString *placeHolderText = _labelPlaceholder.text;
    _labelPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(2, -4, self.frame.size.width - 0, CGRectGetHeight(self.frame))];
    _labelPlaceholder.text = placeHolderText;
    _labelPlaceholder.textAlignment = self.textAlignment;
    _labelPlaceholder.textColor = _placeHolderColor;
    _labelPlaceholder.font = self.font;;
    _labelPlaceholder.hidden = YES;
    [self addSubview:_labelPlaceholder];
}

#pragma mark  Adding Error Label in textfield.
- (void)addErrorPlaceholderLabel{
    [self.labelErrorPlaceholder removeFromSuperview];
    self.labelErrorPlaceholder = [[UILabel alloc] init];
    self.labelErrorPlaceholder.text = self.errorText;
    self.labelErrorPlaceholder.textAlignment = self.textAlignment;
    self.labelErrorPlaceholder.textColor = self.errorTextColor;
    self.labelErrorPlaceholder.font = [UIFont fontWithName:self.font.fontName size:12];
    [self.labelErrorPlaceholder sizeToFit];
    self.labelErrorPlaceholder.hidden = YES;
    [self addSubview:self.labelErrorPlaceholder];
    CGRect frameError = self.labelErrorPlaceholder.frame;
    frameError.origin.x = 0;
    frameError.origin.y = CGRectGetHeight(self.bounds) + 5;
    self.labelErrorPlaceholder.frame = frameError;
}

#pragma mark  Method to show Error Label.
- (void) showErrorPlaceHolder{
    CGRect bottmLineFrame = bottomLineView.frame;
    bottmLineFrame.origin.y = self.frame.size.height - 1;
    if (self.errorText != nil && ![self.errorText isEqualToString:@""]) {
        [self addErrorPlaceholderLabel];
        self.labelErrorPlaceholder.hidden = NO;
        
        [UIView animateWithDuration:0.2 animations:^{
            bottomLineView.frame  =  bottmLineFrame;
            bottomLineView.backgroundColor = _errorLineColor;
            self.labelErrorPlaceholder.alpha = 1;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            bottomLineView.frame  =  bottmLineFrame;
            bottomLineView.backgroundColor = _errorLineColor;
        }];
    }
    
    if (!self.disableShakeWithError) {
        [self shakeView:bottomLineView];
    }
}

#pragma mark  Method to Hide Error Label.
- (void)hideErrorPlaceHolder{
    showingError = NO;
    if (self.errorText == nil || [self.errorText isEqualToString:@""]) {
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.
        labelErrorPlaceholder.alpha = 0;
    } completion:^(BOOL finished) {
        [self.labelErrorPlaceholder removeFromSuperview];
    }];
}

#pragma mark  Update and Manage Subviews
- (void)updateTextField:(CGRect )frame {
    self.frame = frame;
    [self initialization];
}

#pragma mark  Float UITextfield Placeholder Label.
- (void)floatPlaceHolder:(BOOL)selected {
    self.labelPlaceholder.hidden = NO;
    CGRect bottmLineFrame = bottomLineView.frame;
    if (selected) {
        bottomLineView.backgroundColor = self.selectedLineColor;
        self.labelPlaceholder.textColor = self.selectedPlaceHolderColor;
        bottmLineFrame.origin.y = CGRectGetHeight(self.frame) - 1;
        [self setValue:self.selectedPlaceHolderColor forKeyPath:@"_placeholderLabel.textColor"];
    } else {
        bottomLineView.backgroundColor = self.lineColor;
        self.labelPlaceholder.textColor = self.placeHolderColor;
        bottmLineFrame.origin.y = CGRectGetHeight(self.frame)-1;
        [self setValue:self.placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
    }
    if (self.disableFloatingLabel){
        _labelPlaceholder.hidden = YES;
        [UIView animateWithDuration:0.2 animations:^{
            bottomLineView.frame  =  bottmLineFrame;
        }];
        return;
    }
    CGRect frame = self.labelPlaceholder.frame;
    frame.size.height = 12;
    
    [UIView animateWithDuration:0.2 animations:^{
        _labelPlaceholder.frame = frame;
        _labelPlaceholder.font = [UIFont fontWithName:self.font.fontName size:12];
        bottomLineView.frame  =  bottmLineFrame;
        
    }];
    
}

- (void)resignPlaceholder {
    [self setValue:self.placeHolderColor forKeyPath:@"_placeholderLabel.textColor"];
    bottomLineView.backgroundColor = self.lineColor;
    
    CGRect bottmLineFrame = bottomLineView.frame;
    bottmLineFrame.origin.y = CGRectGetHeight(self.frame) - 1;
    
    if (self.disableFloatingLabel){
        self.labelPlaceholder.hidden = YES;
        self.labelPlaceholder.textColor = self.placeHolderColor;
        [UIView animateWithDuration:0.2 animations:^{
            bottomLineView.frame  =  bottmLineFrame;
        }];
        return;
    }
    
    
    CGRect frame = CGRectMake(2, -4, self.frame.size.width-5, self.frame.size.height);
    
    [UIView animateWithDuration:0.3 animations:^{
        _labelPlaceholder.frame = frame;
        _labelPlaceholder.font = self.font;
        _labelPlaceholder.textColor = _placeHolderColor;
        bottomLineView.frame  =  bottmLineFrame;
    } completion:^(BOOL finished) {
        self.labelPlaceholder.hidden = YES;
        self.placeholder = self.labelPlaceholder.text;
    }];
    
}
#pragma mark  UITextField Begin Editing.

- (void)textFieldDidBeginEditing {
    if (showingError) {
        [self hideErrorPlaceHolder];
    }
    if (!self.disableFloatingLabel) {
        self.placeholder = @"";
    }
    
    [self floatTheLabel];
    [self layoutSubviews];
}

#pragma mark  UITextField End Editing.
- (void)textFieldDidEndEditing {
    [self floatTheLabel];
}

#pragma mark  Float & Resign

-(void)floatTheLabel{
    
    if ([self.text isEqualToString:@""] && self.isFirstResponder) {
        
        [self floatPlaceHolder:YES];
        
    }else if ([self.text isEqualToString:@""] && !self.isFirstResponder) {
        
        [self resignPlaceholder];
        
    }else if (![self.text isEqualToString:@""] && !self.isFirstResponder) {
        
        [self floatPlaceHolder:NO];
        
    }else if (![self.text isEqualToString:@""] && self.isFirstResponder) {
        
        [self floatPlaceHolder:YES];
    }
    
}
#pragma mark  Shake Animation
- (void)shakeView:(UIView*)view {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.6;
    animation.values = @[@(-20.0), @20.0, @(-20.0), @20.0, @(-10.0), @10.0, @(-5.0), @(5.0), @(0.0) ];
    [view.layer addAnimation:animation forKey:@"shake"];
}

#pragma mark  Set Placeholder Text On Error Labels
- (void)beginShowError {
    showingError = YES;
    [self showErrorPlaceHolder];
}

- (void)beginHideError {
    showingError = false;
    [self hideErrorPlaceHolder];
    [self floatTheLabel];
}

- (void)showErrorWithText:(NSString *)errorText {
    _errorText = errorText;
    showingError = YES;
    [self showErrorPlaceHolder];
}

#pragma mark  UITextField Responder Overide
- (BOOL)becomeFirstResponder {
    BOOL result = [super becomeFirstResponder];
    [self textFieldDidBeginEditing];
    return result;
}

- (BOOL) resignFirstResponder {
    BOOL result = [super resignFirstResponder];
    [self textFieldDidEndEditing];
    return result;
}

#pragma mark - Error Message

- (void)setErrorMessage:(NSString *)errorMessage {
    [self setErrorText:errorMessage];
}

- (NSString*)errorMessage {
    return  self.errorText;
}
@end
