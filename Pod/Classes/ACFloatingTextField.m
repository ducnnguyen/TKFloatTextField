//
//  AppTextField.m
//  TFDemoApp
//
//  Created by Abhishek Chandani on 19/05/16.
//  Copyright © 2016 Abhishek. All rights reserved.
//

#import "ACFloatingTextField.h"

#define HEXC(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



@implementation PlaceHolderLabel
@end
@interface ACFloatingTextField()
@property (nonatomic, strong) UILabel *errorLabel;
@end

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
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
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
    return CGRectOffset(originalRect, -self.alignRight, 0);
}

#pragma mark:- Override Set text
- (void)setText:(NSString *)text {
    [super setText:text];
    [self floatTheLabel];
}

- (void)initialization {
    
    //HIDE DEFAULT PLACEHOLDER LABEL OF UITEXTFIELD
    
    [self checkForDefaulLabel];
    
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
    
    /// Adding Bottom Line View.
    [self addBottomLineView];
    
    /// Adding Placeholder Label.
    [self addPlaceholderLabel];
    
    
    /// Placeholder Label Configuration.
    if (![self.text isEqualToString:@""]) {
        [self floatTheLabel];
    }
    
}

#pragma mark :- Private Methods
- (void)addBottomLineView{
    [bottomLineView removeFromSuperview];
    bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(2, CGRectGetHeight(self.frame)-5, CGRectGetWidth(self.frame) - 2, 1)];
    bottomLineView.backgroundColor = _lineColor;
    bottomLineView.tag = 20;
    [self addSubview:bottomLineView];
}

- (void)addPlaceholderLabel{
    [_labelPlaceholder removeFromSuperview];
    if (![self.placeholder isEqualToString:@""]&&self.placeholder!=nil) {
        _labelPlaceholder.text = self.placeholder;
    }
    NSString *placeHolderText = _labelPlaceholder.text;
    _labelPlaceholder = [[PlaceHolderLabel alloc] initWithFrame:CGRectMake(1, 0, self.frame.size.width-1, CGRectGetHeight(self.frame)+4)];
    _labelPlaceholder.text = placeHolderText;
    _labelPlaceholder.textAlignment = self.textAlignment;
    _labelPlaceholder.textColor = _placeHolderColor;
    _labelPlaceholder.font = self.font;;
    _labelPlaceholder.tag = 21;
    [self addSubview:_labelPlaceholder];
}

- (UILabel*)errorLabel{
    if (_errorLabel == nil) {
        _errorLabel = [[UILabel alloc]initWithFrame:CGRectMake(1, CGRectGetHeight(self.frame) + 4, self.frame.size.width-1, 14)];
        _errorLabel.textAlignment = NSTextAlignmentLeft;;
        _errorLabel.textColor = HEXC(0xe53935);
        _errorLabel.font = [UIFont systemFontOfSize:12.f];
        _errorLabel.tag = 22;
        [self addSubview:_errorLabel];
        _errorLabel.hidden = !self.showError;
    }
    _errorLabel.frame = CGRectMake(1, CGRectGetHeight(self.frame) + 4, self.frame.size.width-1, 14);
    return _errorLabel;
}

/// Hadling The Default Placeholder Label
- (void)checkForDefaulLabel{
    if ([self.text isEqualToString:@""]) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[PlaceHolderLabel class]]) {
                
                PlaceHolderLabel *newLabel = (PlaceHolderLabel *)view;
                if (newLabel.tag!=21) {
                    newLabel.hidden = YES;
                }
            }
        }
        
    } else {
        
        for (UIView *view in self.subviews) {
            
            if ([view isKindOfClass:[PlaceHolderLabel class]]) {
                
                PlaceHolderLabel *newLabel = (PlaceHolderLabel *)view;
                if (newLabel.tag!=21) {
                    newLabel.hidden = NO;
                }
            }
        }
        
    }
    
}

#pragma mark  Upadate and Manage Subviews
- (void)updateTextField:(CGRect )frame {
    self.frame = frame;
    [self initialization];
}

#pragma mark  Float UITextfield Placeholder Label.
- (void)floatPlaceHolder:(BOOL)selected {
    if (selected) {
        bottomLineView.backgroundColor = _selectedLineColor;
        
        if (self.disableFloatingLabel) {
            _labelPlaceholder.hidden = YES;
            CGRect bottmLineFrame = bottomLineView.frame;
            bottmLineFrame.origin.y = CGRectGetHeight(self.frame)-5;
            [UIView animateWithDuration:0.2 animations:^{
                bottomLineView.frame  =  bottmLineFrame;
            }];
            return;
        }
        
        CGRect frame = _labelPlaceholder.frame;
        frame.size.height = 12;
        CGRect bottmLineFrame = bottomLineView.frame;
        bottmLineFrame.origin.y = CGRectGetHeight(self.frame)-5;
        [UIView animateWithDuration:0.2 animations:^{
            _labelPlaceholder.frame = frame;
            _labelPlaceholder.font = [UIFont fontWithName:self.font.fontName size:12];
            _labelPlaceholder.textColor = _selectedPlaceHolderColor;
            bottomLineView.frame  =  bottmLineFrame;
            
        }];
        
    } else {
        bottomLineView.backgroundColor = _lineColor;
        if (self.disableFloatingLabel){
            _labelPlaceholder.hidden = YES;
            CGRect bottmLineFrame = bottomLineView.frame;
            bottmLineFrame.origin.y = CGRectGetHeight(self.frame)-5;
            [UIView animateWithDuration:0.2 animations:^{
                bottomLineView.frame  =  bottmLineFrame;
            }];
            return;
        }
        
        CGRect frame = _labelPlaceholder.frame;
        frame.size.height = 12;
        CGRect bottmLineFrame = bottomLineView.frame;
        bottmLineFrame.origin.y = CGRectGetHeight(self.frame)-5;
        [UIView animateWithDuration:0.2 animations:^{
            _labelPlaceholder.frame = frame;
            _labelPlaceholder.font = [UIFont fontWithName:self.font.fontName size:12];
            _labelPlaceholder.textColor = _placeHolderColor;
            bottomLineView.frame  =  bottmLineFrame;
        }];
    }
}

- (void)resignPlaceholder{
    bottomLineView.backgroundColor = _lineColor;
    if (self.disableFloatingLabel) {
        _labelPlaceholder.hidden = NO;
        _labelPlaceholder.textColor = _placeHolderColor;
        CGRect bottmLineFrame = bottomLineView.frame;
        bottmLineFrame.origin.y = CGRectGetHeight(self.frame)-5;
        [UIView animateWithDuration:0.2 animations:^{
            bottomLineView.frame  =  bottmLineFrame;
        }];
        return;
    }
    
    
    CGRect frame = CGRectMake(2, 0, self.frame.size.width - 2, self.frame.size.height+4);
    CGRect bottmLineFrame = bottomLineView.frame;
    bottmLineFrame.origin.y = CGRectGetHeight(self.frame) - 5;
    [UIView animateWithDuration:0.2 animations:^{
        _labelPlaceholder.frame = frame;
        _labelPlaceholder.font = self.font;
        _labelPlaceholder.textColor = _placeHolderColor;
        bottomLineView.frame  =  bottmLineFrame;
    }];

}
#pragma mark  UITextField Begin Editing.

- (void)textFieldDidBeginEditing {
    [self floatTheLabel];
    [self layoutSubviews];
}

#pragma mark  UITextField End Editing.
- (void)textFieldDidEndEditing {
    [self floatTheLabel];
}

#pragma mark  Float & Resign

- (void)floatTheLabel{
    
    if ([self.text isEqualToString:@""]&&self.isFirstResponder) {
        
        [self floatPlaceHolder:YES];
        
    }else if ([self.text isEqualToString:@""]&&!self.isFirstResponder) {
    
        [self resignPlaceholder];
        
    }else if (![self.text isEqualToString:@""]&&!self.isFirstResponder) {
        
        [self floatPlaceHolder:NO];
        
    }else if (![self.text isEqualToString:@""]&&self.isFirstResponder) {
        
        [self floatPlaceHolder:YES];
    }

    [self checkForDefaulLabel];

}


#pragma mark  Set Placeholder Text On Labels
-(void)setTextFieldPlaceholderText:(NSString *)placeholderText {
    
    self.labelPlaceholder.text = placeholderText;
    [self textFieldDidEndEditing];
}
-(void)setPlaceholder:(NSString *)placeholder {
    
    self.labelPlaceholder.text = placeholder;
    [self textFieldDidEndEditing];
    
}
#pragma mark  UITextField Responder Overide
- (BOOL)becomeFirstResponder {

    BOOL result = [super becomeFirstResponder];
    [self textFieldDidBeginEditing];
    return result;
}

-(BOOL)resignFirstResponder {

    BOOL result = [super resignFirstResponder];
    [self textFieldDidEndEditing];
    return result;
}
#pragma mark - Error Message
- (void)setShowError:(BOOL)showError {
    _showError = showError;
    self.errorLabel.hidden = !showError;
}
- (void)setErrorMessage:(NSString *)errorMessage {
    _errorMessage = errorMessage;
    [self.errorLabel setText:errorMessage];
}
@end
