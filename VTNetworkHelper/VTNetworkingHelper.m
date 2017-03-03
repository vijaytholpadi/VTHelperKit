//
//  VTNetworkingHelper.m
//
//  Created by Vijay Tholpadi on 9/29/14.
//  Copyright (c) 2014 TheGeekProjekt. All rights reserved.
//

#import "VTNetworkingHelper.h"

@interface VTNetworkingHelper ()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@end

@implementation VTNetworkingHelper

+ (VTNetworkingHelper *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [self setupSessionManager];
    });
    return sharedInstance;
}

- (void)setupSessionManager {
    self.sessionManager = [AFHTTPSessionManager manager];

    //Comment the following line if you want to disable SSL Certificate pinning. It is currently operating in the Public key pinning mode
    [setupSessionManager setupSSLCertificatePinningOnSessionManager:self.sessionManager];
}

- (void)setupSSLCertificatePinningOnSessionManager:(AFHTTPSessionManager*)sessionManager {
    NSSet *certificates = [AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey
                                                withPinnedCertificates:certificates];
    sessionManager.securityPolicy = policy;
}

- (void)performRequestWithPath:(NSString *)path
                      withAuth:(BOOL)needsAuth
     withRequestJSONSerialized:(BOOL)reqJSONSerialized
         withCompletionHandler:(VTNetworkRequestCompletionHandler)handler {
    
    [self performRequestWithPath:path
                        withAuth:needsAuth
                       forMethod:@"GET"
       withRequestJSONSerialized:reqJSONSerialized
                      withParams:nil
           withCompletionHandler:handler];
}

- (void)performRequestWithPath:(NSString *)path
                      withAuth:(BOOL)needsAuth
                     forMethod:(NSString *)method
     withRequestJSONSerialized:(BOOL)reqJSONSerialized
                    withParams:(id)params
         withCompletionHandler:(VTNetworkRequestCompletionHandler)handler {

    //Setting the request Serializer based on flag (Should consider changing this to Enum)
    if(reqJSONSerialized == NO){
        self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    } else {
        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self.sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    }

    //Check if auth is necessary
    if (needsAuth){
        [sessionManager setAuthOnSessionManager:self.sessionManager];
    } else {
        [self.sessionManager.requestSerializer clearAuthorizationHeader];
    }

    //Setting the response serializer to JSON by default
    [self setResponseSerializerForSessionManager:self.sessionManager];

    //Showing the network progress indicator before every request
    [self activityIndicatorShouldShow:YES];
    
    //Depending on the method type we proceed to the corresponding execution
    if ([method isEqualToString:@"GET"]) {
        [self.sessionManager GET:path parameters:params
                        progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self activityIndicatorShouldShow:NO];
            if (handler) {
                handler([self prepareResponseObject:TRUE withData:responseObject andError:nil]);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse*)task.response;
            if ([castedResponse statusCode] == 401) {
                NSLog(@"error code %@",[castedResponse allHeaderFields]);
                //Handle logic for forbidden request
                return;
            }

            [self activityIndicatorShouldShow:NO];

            if (NSLocationInRange(castedResponse.statusCode, NSMakeRange(400, 99))) {
                if(handler) {
                    VTError *errorDetails = [[VTError alloc] init];
                    errorDetails.errorDictionary = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
                    errorDetails.error = error;

                    handler([self prepareResponseObject:FALSE withData:nil andError:errorDetails]);
                }
            }

            if ((error.code == -1009) || (error.code == -1001)) {
                VTError *errorDetails = [[VTError alloc] init];
                errorDetails.error = error;
                handler([self prepareResponseObject:FALSE withData:nil andError:errorDetails]);
            }
        }];
        
    } else if([method isEqualToString:@"POST"]) {
        [self.sessionManager POST:path parameters:params
                         progress:^(NSProgress * _Nonnull uploadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self activityIndicatorShouldShow:NO];
            if(handler) {
                handler([self prepareResponseObject:TRUE withData:responseObject andError:nil]);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse*)task.response;
            if (castedResponse.statusCode == 401) {
                NSLog(@"error code %@",[castedResponse allHeaderFields]);
                //Handle logic for forbidden request
                return;
            }

            [self activityIndicatorShouldShow:NO];

            if (NSLocationInRange(castedResponse.statusCode, NSMakeRange(400, 99))) {
                if(handler) {
                    VTError *errorDetails = [[VTError alloc] init];
                    errorDetails.errorDictionary = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
                    errorDetails.error = error;
                    handler([self prepareResponseObject:FALSE withData:nil andError:errorDetails]);
                }
            }
            
            if ((error.code == -1009) || (error.code == -1001)) {
                VTError *errorDetails = [[VTError alloc] init];
                errorDetails.error = error;
                handler([self prepareResponseObject:FALSE withData:nil andError:errorDetails]);
            }
        }];
        
    } else if ([method isEqualToString:@"PUT"]) {
        [self.sessionManager PUT:path parameters:params
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 [self activityIndicatorShouldShow:NO];
                 if (handler) {
                     handler([self prepareResponseObject:TRUE withData:responseObject andError:nil]);
                 }
             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse*)task.response;
                 if (castedResponse.statusCode == 401) {
                     NSLog(@"error code %@",[castedResponse allHeaderFields]);
                     //Handle logic for forbidden request
                     return;
                 }

                 [self activityIndicatorShouldShow:NO];

                 if (NSLocationInRange(castedResponse.statusCode, NSMakeRange(400, 99))) {
                     if(handler) {
                         VTError *errorDetails = [[VTError alloc] init];
                         errorDetails.errorDictionary = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
                         errorDetails.error = error;
                         
                         handler([self prepareResponseObject:FALSE withData:nil andError:errorDetails]);
                     }
                 }
                 
                 if ((error.code == -1009) || (error.code == -1001)) {
                     VTError *errorDetails = [[VTError alloc] init];
                     errorDetails.error = error;
                     handler([self prepareResponseObject:FALSE withData:nil andError:errorDetails]);
                 }
             }];
        
    } else if ([method isEqualToString:@"DELETE"]) {
        [self.sessionManager DELETE:path parameters:params
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self activityIndicatorShouldShow:NO];
            if (handler) {
                handler([self prepareResponseObject:TRUE withData:responseObject andError:nil]);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse*)task.response;
            if (castedResponse.statusCode == 401) {
                NSLog(@"error code %@",[castedResponse allHeaderFields]);
                //Handle logic for forbidden request
                return;
            }

            [self activityIndicatorShouldShow:NO];

            if (NSLocationInRange(castedResponse.statusCode, NSMakeRange(400, 99))) {
                if(handler) {
                    VTError *errorDetails = [[VTError alloc] init];
                    errorDetails.errorDictionary = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
                    errorDetails.error = error;

                    handler([self prepareResponseObject:FALSE withData:nil andError:errorDetails]);
                }
            }
            
            if ((error.code == -1009) || (error.code == -1001)) {
                VTError *errorDetails = [[VTError alloc] init];
                errorDetails.error = error;
                handler([self prepareResponseObject:FALSE withData:nil andError:errorDetails]);
            }
        }];
    }
}

- (void)setAuthOnSessionManager:(AFHTTPSessionManager*)sessionManager {
    //Use this line to set the auth token on your request
    [self.sessionManager.requestSerializer setValue:[NSString stringWithFormat:@"Token token=%@",@"<Insert Auth Token here>"] forHTTPHeaderField:@"Authorization"];
}

- (void)setResponseSerializerForSessionManager:(AFHTTPSessionManager*)sessionManager {
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.sessionManager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    self.sessionManager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
}

#pragma mark - Helper functions
- (VTNetworkResponse *)prepareResponseObject:(BOOL) success
                                    withData:(id)response
                                    andError: (VTError *)error {
    VTNetworkResponse *responseDetails = [[VTNetworkResponse alloc] init];
    responseDetails.isSuccessful = success;
    responseDetails.data = response;
    responseDetails.error = error;
    return responseDetails;
}

- (void)dealloc {
}

#pragma mark - UIActivityIndicator Helper
- (void)activityIndicatorShouldShow:(BOOL)shouldShow {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = shouldShow;
}

@end

