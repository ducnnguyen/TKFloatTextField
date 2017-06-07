//
//  TKAutoFillTextField.m
//  TikiProject
//
//  Created by TruongQuangMinh on 12/26/16.
//  Copyright © 2016 Tiki.vn. All rights reserved.
//

#import "TKAutoFillTextField.h"

@interface TKAutoFillTextField()

@property (strong, nonatomic) NSString *predicatedText;

@end

@implementation TKAutoFillTextField

#pragma mark - Loading From NIB

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUp];
}

#pragma mark - Initialization Methods
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.spellCheckingType = UITextSpellCheckingTypeNo;
    if (self.autoCompletedType == AutoCompletedType_Email) {
        self.dataSource = @[@"gmail.com",
                            @"tiki.vn",
                            @"yahoo.com",
                            @"hotmail.com",
                            @"outlook.com",
                            @"inbox.com",
                            @"mail.com",
                            @"icloud.com",
                            @"aol.com",
                            @"zoho.com",
                            @"yandex.com",
                            @"hushmail.com",
                            @"lazada.vn",
                            @"lazada.com",
                            @"adayroi.com",
                            @"lotte.vn",
                            @"sendo.vn",
                            @"dienmayxanh.com",
                            @"thegioididong.com",
                            @"fpt.com.vn",
                            @"vng.com.vn",
                            @"shopee.vn",
                            @"vuivui.com"];
    }
    
    
    [self addTarget:self action:@selector(textFieldDidChanged) forControlEvents:UIControlEventEditingChanged];
}

- (NSString *)textAfterInput:(NSString *)originText {
    NSRange atSignRange = [originText rangeOfString:@"@"];
    if (atSignRange.location == NSNotFound)
    {
        return @"";
    }
    // Check that there aren't two @-signs
    NSArray *textComponents = [originText componentsSeparatedByString:@"@"];
    if ([textComponents count] > 2)
    {
        return @"";
    }
    
    if ([textComponents count] > 1) // has after @
    {
        // If no domain is entered, use the first domain in the list
        if ([(NSString *)textComponents[1] length] == 0)
        {
            return [self.dataSource objectAtIndex:0];
        }
        
        NSString *textAfterAtSign = textComponents[1];
        return textAfterAtSign;
    }
    return @"";
}

- (void)textFieldDidChanged {
    
    NSString *editedText = self.text;
    if (self.autoCompletedType == AutoCompletedType_Email) {
        editedText = [editedText stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.text = editedText;
    }
    if (!editedText) {
        return;
    }
    @weakify(self);
    dispatch_block_t doAutoCompleteForEmailBlock = ^{
        @strongify(self);
        if (self.dataSource.count > 0) {
            [self autoCompleteEmailWithEditedText:editedText dataSource:self.dataSource];
        }
    };
    dispatch_block_t doAutoCompleteBlock = ^ {
        @strongify(self);
        if (self.dataSource.count > 0) {
            [self autoCompleteWithEditedText:editedText dataSource:self.dataSource];
        }
    };
    
    if(self.autoCompletedType == AutoCompletedType_Email)
    {
        if (![NSThread mainThread]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                doAutoCompleteForEmailBlock();
            });
        }else {
            doAutoCompleteForEmailBlock();
        }        return;
    } else if(self.autoCompletedType == AutoCompletedType_Phone){
        self.dataSource = [Constants userPhones];
        if (![NSThread mainThread]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                doAutoCompleteBlock();
            });
        }else {
            doAutoCompleteBlock();
        }
        return;
    }else {
        if (![NSThread mainThread]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                doAutoCompleteBlock();
            });
        }else {
            doAutoCompleteBlock();
        }    }
}

- (void)autoCompleteEmailWithEditedText:(NSString*)editedText dataSource:(NSArray*)dataSource {
    NSString *textAfterInput = [self textAfterInput:editedText];
    
    if ([textAfterInput isEmptyString]) {
        NSString *email = [AccountManager sharedInstance].loggedUser.email;
        if ([AccountManager sharedInstance].isLoggedIn && email) {
            [self autoCompleteWithEditedText:editedText dataSource:@[email]];
        }
    } else {
        NSArray *suggessArr = [dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] %@", textAfterInput]];
        
        if (suggessArr.count > 0) {
            NSString *suggestededText = suggessArr[0];
            NSString *suggestedAppend = [suggestededText substringFromIndex:textAfterInput.length];
            
            if ([suggestedAppend isEqualToString:@""])
                return;
            
            BOOL hasRemovedText = NO;
            if ([suggestedAppend isEqualToString:self.predicatedText]) {
                self.predicatedText = [suggestededText substringFromIndex:textAfterInput.length-1];
                suggestedAppend = @"";
                hasRemovedText = YES;
            } else {
                self.predicatedText = suggestedAppend;
            }
            self.text = [self.text stringByAppendingString:suggestedAppend];
            if (self.didAutoFill  && self.text != nil) {
                self.didAutoFill();
            }
            if (hasRemovedText)
                return;
            
            // Get current selected range , this example assumes is an insertion point or empty selection
            UITextRange *selectedRange = [self selectedTextRange];
            
            // Calculate the new position, - for left and + for right
            UITextPosition *newPosition = [self positionFromPosition:selectedRange.start offset:-suggestedAppend.length];
            
            // Construct a new range using the object that adopts the UITextInput, our textfield
            UITextRange *newRange = [self textRangeFromPosition:newPosition toPosition:selectedRange.start];
            [self setSelectedTextRange:newRange];

        }
    }
}

- (void)autoCompleteWithEditedText:(NSString*)editedText dataSource:(NSArray*)dataSource {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] %@", editedText];
    NSArray *fillterPhones = [dataSource filteredArrayUsingPredicate:predicate];
    if (fillterPhones.count > 0) {
        NSString *firstNumber = fillterPhones[0];
        NSString *additionalPath = [firstNumber substringFromIndex:editedText.length];
        
        if ([additionalPath isEqualToString:@""])
            return;
        
        BOOL hasRemovedText = NO;
        if ([additionalPath isEqualToString:self.predicatedText]) {
            self.predicatedText = [firstNumber substringFromIndex:editedText.length-1];
            additionalPath = @"";
            hasRemovedText = YES;
            additionalPath = self.predicatedText;
        } else {
            self.predicatedText = additionalPath;
        }
        self.text = firstNumber;
        if (self.didAutoFill && self.text != nil) {
            self.didAutoFill();
        }
        // Get current selected range , this example assumes is an insertion point or empty selection
        UITextRange *selectedRange = [self selectedTextRange];
        
        // Calculate the new position, - for left and + for right
        UITextPosition *newPosition = [self positionFromPosition:selectedRange.start offset:-additionalPath.length];
        
        // Construct a new range using the object that adopts the UITextInput, our textfield
        UITextRange *newRange = [self textRangeFromPosition:newPosition toPosition:selectedRange.start];
        [self setSelectedTextRange:newRange];

    }
}

@end
