//
//  VTDeviceHelper.h
//  TheGeekProjekt
//
//  Created by Vijay Tholpadi on 6/2/15.
//  Copyright (c) 2015 TheGeekProjekt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTError : NSObject
@property (nonatomic, strong) NSDictionary *errorDictionary;
@property (nonatomic, strong) NSError * error;
@end
