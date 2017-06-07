//
//  TKAutoFillTextField.h
//  TikiProject
//
//  Created by TruongQuangMinh on 12/26/16.
//  Copyright © 2016 Tiki.vn. All rights reserved.
//

#import "ACFloatingTextField.h"
typedef enum {
    AutoCompletedType_Email = 0,
    AutoCompletedType_Phone
}AutoCompletedType;

@interface TKAutoFillTextField : ACFloatingTextField

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic) AutoCompletedType autoCompletedType;
@property (nonatomic, copy) void(^didAutoFill)();

@end
