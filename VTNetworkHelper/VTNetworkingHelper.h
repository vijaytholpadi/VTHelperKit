//
//  VTNetworkingHelper.h
//
//  Created by Vijay Tholpadi on 9/29/14.
//  Copyright (c) 2014 TheGeekProjekt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

//Models
#import "VTNetworkResponse.h"

typedef void (^VTNetworkRequestCompletionHandler) (VTNetworkResponse * response);

@interface VTNetworkingHelper : NSObject

// Network operation functions
/*
- For GET requests the performRequestWithPath should be called as there is
 no need to send parameters.
*/
- (void)performRequestWithPath:(NSString *)path
                      withAuth:(BOOL)needsAuth
     withRequestJSONSerialized:(BOOL)reqJSONSerialized
         withCompletionHandler:(VTNetworkRequestCompletionHandler)handler;

/*
- For POST, PUT and DELETE requests the performRequestWithPath:withParams needs
 to be called with the necessary parameters.
 */
- (void)performRequestWithPath:(NSString *)path
                      withAuth:(BOOL)needsAuth
                     forMethod:(NSString *)method
     withRequestJSONSerialized:(BOOL)reqJSONSerialized
                    withParams:(id)params
         withCompletionHandler:(VTNetworkRequestCompletionHandler)handler;

//Class methods - Shared Instance
+ (VTNetworkingHelper *)sharedInstance;

@end
