//
//  Connector.m
//  StockList Demo for iOS
//
// Copyright (c) Lightstreamer Srl
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Connector.h"
#import "Constants.h"


static Connector *__sharedInstace= nil;

@implementation Connector


#pragma mark -
#pragma mark Singleton access

+ (Connector *) sharedConnector {
	if (!__sharedInstace) {
		@synchronized ([Connector class]) {
			if (!__sharedInstace)
				__sharedInstace= [[Connector alloc] init];
		}
	}
	
	return __sharedInstace;
}


#pragma mark -
#pragma mark Initialization

- (id) init {
	if ((self = [super init])) {
		
        // Uncomment to enable detailed logging
//      [LSLightstreamerClient setLoggerProvider:[[LSConsoleLoggerProvider alloc] initWithLevel:LSConsoleLogLevelDebug]];

        // Initialization
		_client= [[LSLightstreamerClient alloc] initWithServerAddress:PUSH_SERVER_URL adapterSet:ADAPTER_SET];
		[_client addDelegate:self];
	}
	
	return self;
}


#pragma mark -
#pragma mark Operations

- (void) connect {
	NSLog(@"Connector: connecting...");

	[_client connect];
}

- (void) subscribe:(LSSubscription *)subscription {
	NSLog(@"Connector: subscribing...");

	[_client subscribe:subscription];
}

- (void) unsubscribe:(LSSubscription *)subscription {
	NSLog(@"Connector: subscribing...");

	[_client unsubscribe:subscription];
}


#pragma mark -
#pragma mark Properties

@dynamic connected;

- (BOOL) isConnected {
	return [_client.status hasPrefix:@"CONNECTED:"];
}

@dynamic connectionStatus;

- (NSString *) connectionStatus {
	return _client.status;
}


#pragma mark -
#pragma mark Methods of LSClientDelegate

- (void) client:(nonnull LSLightstreamerClient *)client didChangeProperty:(nonnull NSString *)property {
	NSLog(@"Connector: property changed: %@", property);
}

- (void) client:(nonnull LSLightstreamerClient *)client didChangeStatus:(nonnull NSString *)status {
	NSLog(@"Connector: status changed: %@", status);
	
	if ([status hasPrefix:@"CONNECTED:"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONN_STATUS object:self];
	
	} else if ([status hasPrefix:@"DISCONNECTED:"]) {
		
		// The LSLightstreamerClient will reconnect automatically in this case.
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONN_STATUS object:self];
		
	} else if ([status isEqualToString:@"DISCONNECTED"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONN_STATUS object:self];
		
		// In this case the session has been forcibly closed by the server,
		// the LSLightstreamerClient will not automatically reconnect, notify the observers
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONN_ENDED object:self];
	}
}

- (void) client:(nonnull LSLightstreamerClient *)client didReceiveServerError:(NSInteger)errorCode withMessage:(nullable NSString *)errorMessage {
	NSLog(@"Connector: server error: %ld - %@", (long) errorCode, errorMessage);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONN_STATUS object:self];
}


@end
