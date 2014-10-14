//
//  Connector.m
//  StockList Demo for iOS
//
// Copyright 2013 Weswit Srl
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
		
		// Nothing to do
	}
	
	return self;
}


#pragma mark -
#pragma mark Operations

- (void) connect {
	if (!_client)
		_client= [LSClient client];

	@try {
		NSLog(@"Connector: connecting to Lightstreamer Server...");
		
		LSConnectionInfo *connectionInfo= [LSConnectionInfo connectionInfoWithPushServerURL:PUSH_SERVER_URL
																	   pushServerControlURL:nil
																					   user:nil
																				   password:nil
																					adapter:ADAPTER_SET];

		[_client openConnectionWithInfo:connectionInfo delegate:self];
		
		NSLog(@"Connector: connected");

	} @catch (NSException *e) {
		NSLog(@"Connector: exception caught while connecting: %@", e);
	}
}


#pragma mark -
#pragma mark Properties

@synthesize client= _client;


#pragma mark -
#pragma mark Methods of LSConnectionDelegate

- (void) clientConnection:(LSClient *)client didStartSessionWithPolling:(BOOL)polling {
	NSLog(@"Connector: session started with polling: %@", (polling ? @"YES" : @"NO"));
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONN_STATUS object:self];
}

- (void) clientConnection:(LSClient *)client didChangeActivityWarningStatus:(BOOL)warningStatus {
	NSLog(@"Connector: activity warning status changed: %@", (warningStatus ? @"ON" : @"OFF"));
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONN_STATUS object:self];
}

- (void) clientConnectionDidEstablish:(LSClient *)client {
	NSLog(@"Connector: connection established");
}

- (void) clientConnectionDidClose:(LSClient *)client {
	NSLog(@"Connector: connection closed");
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONN_STATUS object:self];
	
	// This event is called just by manually closing the connection,
	// never happens in this example.
}

- (void) clientConnection:(LSClient *)client didEndWithCause:(int)cause {
	NSLog(@"Connector: connection ended with cause: %d", cause);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONN_STATUS object:self];
	
	// In this case the session has been forcibly closed by the server,
	// the LSClient will not automatically reconnect, notify the observers
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONN_ENDED object:self];
}

- (void) clientConnection:(LSClient *)client didReceiveDataError:(LSPushServerException *)error {
	NSLog(@"Connector: data error: %@", error);
}

- (void) clientConnection:(LSClient *)client didReceiveServerFailure:(LSPushServerException *)failure {
	NSLog(@"Connector: server failure: %@", failure);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONN_STATUS object:self];
	
	// The LSClient will reconnect automatically in this case.
}

- (void) clientConnection:(LSClient *)client didReceiveConnectionFailure:(LSPushConnectionException *)failure {
	NSLog(@"Connector: connection failure: %@", failure);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONN_STATUS object:self];
	
	// The LSClient will reconnect automatically in this case.
}

- (void) clientConnection:(LSClient *)client isAboutToSendURLRequest:(NSMutableURLRequest *)urlRequest {}


@end
