//
//  VTNetworkingHelper.m
//
//  Created by Vijay Tholpadi on 9/29/14.
//  Copyright (c) 2014 TheGeekProjekt. All rights reserved.
//

#import "VTNetworkingHelper.h"
#import "MMAppDelegate.h"
#import "MMUser.h"


@implementation VTNetworkingHelper

-(id)init{
    if (self = [super init]) {
    }
    return self;
}


+ (VTNetworkingHelper *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}


- (void)performRequestWithPath:(NSString *)path withAuth:(BOOL)needsAuth withRequestJSONSerialized:(BOOL)reqJSONSerialized withCompletionHandler:(VTNetworkRequestCompletionHandler) handler {
    
    [self performRequestWithPath:path withAuth:needsAuth forMethod:@"GET" withRequestJSONSerialized:reqJSONSerialized withParams:nil withCompletionHandler:handler];
}


- (void)performRequestWithPath:(NSString *)path withAuth:(BOOL)needsAuth forMethod:(NSString *)method withRequestJSONSerialized:(BOOL)reqJSONSerialized withParams:(id)params withCompletionHandler:(VTNetworkRequestCompletionHandler) handler {
    
    self.isInternetViewVisible = NO;
    
    //Reachability detection
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                [self LoadNoInternetView:NO];
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                [self LoadNoInternetView:NO];
                break;
            }
            case AFNetworkReachabilityStatusNotReachable: {
                break;
            }
            default: {
                break;
            }
        }
    }];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSSet *certificates = [AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey withPinnedCertificates:certificates];
    manager.securityPolicy = policy;
    
    if(reqJSONSerialized == NO){
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    } else {
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    }
    
    if (needsAuth){
        [manager.requestSerializer clearAuthorizationHeader];

        //Set the user API token here. Need to refactor.
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Token token=%@",[MMUser getUserAPIToken]] forHTTPHeaderField:@"Authorization"];
    }
    
    manager.responseSerializer =[AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //Depending on the method type we proceed to the corresponding execution
    if([method isEqualToString:@"POST"]) {
        [manager POST:path parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            if(handler) {
                handler([self prepareResponseObject:TRUE withData:responseObject andError:nil]);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse*)task.response;
            if (castedResponse.statusCode == 401) {
                NSLog(@"error code %@",[castedResponse allHeaderFields]);
                [[MMAppDelegate sharedInstance] resetApp];
                return;
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

            if (NSLocationInRange(castedResponse.statusCode, NSMakeRange(400, 99))) {
                if(handler) {
                    VTError *errorDetails = [[VTError alloc] init];
                    errorDetails.errorDictionary = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
                    errorDetails.error = error;
                    handler([self prepareResponseObject:FALSE withData:nil andError:errorDetails]);
                }
            }
            
            if ((error.code == -1009) || (error.code == -1001)) {
                [self LoadNoInternetView:YES];
                VTError *errorDetails = [[VTError alloc] init];
                errorDetails.error = error;
                handler([self prepareResponseObject:FALSE withData:nil andError:errorDetails]);
            }
        }];
        
    } else if ([method isEqualToString:@"GET"]) {
        [manager GET:path parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (handler) {
                handler([self prepareResponseObject:TRUE withData:responseObject andError:nil]);
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse*)task.response;
            if ([castedResponse statusCode] == 401) {
                NSLog(@"error code %@",[castedResponse allHeaderFields]);
                [[MMAppDelegate sharedInstance] resetApp];
                return;
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

            if (NSLocationInRange(castedResponse.statusCode, NSMakeRange(400, 99))) {
                if(handler) {
                    VTError *errorDetails = [[VTError alloc] init];
                    errorDetails.errorDictionary = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
                    errorDetails.error = error;
                    
                    handler([self prepareResponseObject:FALSE withData:nil andError:errorDetails]);
                }
            }
            
            if ((error.code == -1009) || (error.code == -1001)) {
                [self LoadNoInternetView:YES];
                VTError *errorDetails = [[VTError alloc] init];
                errorDetails.error = error;
                handler([self prepareResponseObject:FALSE withData:nil andError:errorDetails]);
            }
        }];
        
    } else if ([method isEqualToString:@"PUT"]) {
        [manager PUT:path parameters:params
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 if (handler) {
                     handler([self prepareResponseObject:TRUE withData:responseObject andError:nil]);
                 }
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 
             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse*)task.response;
                 if (castedResponse.statusCode == 401) {
                     NSLog(@"error code %@",[castedResponse allHeaderFields]);
                     [[MMAppDelegate sharedInstance] resetApp];
                     return;
                 }
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

                 if (NSLocationInRange(castedResponse.statusCode, NSMakeRange(400, 99))) {
                     if(handler) {
                         VTError *errorDetails = [[VTError alloc] init];
                         errorDetails.errorDictionary = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
                         errorDetails.error = error;
                         
                         handler([self prepareResponseObject:FALSE withData:nil andError:errorDetails]);
                     }
                 }
                 
                 if ((error.code == -1009) || (error.code == -1001)) {
                     [self LoadNoInternetView:YES];
                     VTError *errorDetails = [[VTError alloc] init];
                     errorDetails.error = error;
                     handler([self prepareResponseObject:FALSE withData:nil andError:errorDetails]);
                 }
             }];
        
    } else if ([method isEqualToString:@"DELETE"]) {
        [manager DELETE:path parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (handler) {
                handler([self prepareResponseObject:TRUE withData:responseObject andError:nil]);
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse*)task.response;
            if (castedResponse.statusCode == 401) {
                NSLog(@"error code %@",[castedResponse allHeaderFields]);
                [[MMAppDelegate sharedInstance] resetApp];
                return;
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

            if (NSLocationInRange(castedResponse.statusCode, NSMakeRange(400, 99))) {
                if(handler) {
                    VTError *errorDetails = [[VTError alloc] init];
                    errorDetails.errorDictionary = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
                    errorDetails.error = error;
                    
                    handler([self prepareResponseObject:FALSE withData:nil andError:errorDetails]);
                }
            }
            
            if ((error.code == -1009) || (error.code == -1001)) {
                [self LoadNoInternetView:YES];
                VTError *errorDetails = [[VTError alloc] init];
                errorDetails.error = error;
                handler([self prepareResponseObject:FALSE withData:nil andError:errorDetails]);
            }
        }];
    }
}


#pragma mark - Helper functions
- (VTNetworkResponse *)prepareResponseObject:(BOOL) success
                                    withData:(id)response
                                    andError: (VTError *)error{
    VTNetworkResponse *responseDetails = [[VTNetworkResponse alloc] init];
    responseDetails.isSuccessful = success;
    responseDetails.data = response;
    responseDetails.error = error;
    return responseDetails;
}


-(void)LoadNoInternetView:(BOOL)Show {
    
    if ([[[UIApplication sharedApplication] keyWindow].subviews containsObject: self.noInternetView] == Show) {
        return;
        
    }
    
    if (Show) {
        
        if (!self.noInternetView) {
            
            self.isInternetViewVisible = YES;
            UINib *nib = [UINib nibWithNibName:@"VTNoInternetView" bundle:nil];
            self.noInternetView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
            
            self.noInternetView.frame = [[UIApplication sharedApplication] keyWindow].frame;
            
            self.noInternetView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        }
        
        BOOL addinternetView = YES;
        
        MMAppDelegate *myAppDelegate = (MMAppDelegate*)[[UIApplication sharedApplication]delegate];
        
        for(UIView *view in myAppDelegate.window.subviews)
        {
            if([view isKindOfClass:[VTNoInternetView class]])
            {
                addinternetView = NO;
            }
        }
        
        if (addinternetView) {
            [[[UIApplication sharedApplication] keyWindow] addSubview: self.noInternetView];
        }
    } else {
        self.isInternetViewVisible = NO;
        
        [self.noInternetView removeFromSuperview];
    }
}


- (void)dealloc {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (AFNetworkReachabilityStatus)getReachabilityStatus
{
    return [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
}

@end

