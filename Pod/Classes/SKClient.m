//
//  SKClient.m
//  StatKit
//
//  Created by Steven Chan on 26/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#import "SKClient.h"
#import "SKSession.h"

#import "Reachability.h"
#import "NSDate+UnixTimestamp.h"
#import "NSString+Hash.h"
#import "PublicIPRetriever.h"
#import "SimpleIPResultParser.h"
#import "SimpleJSONIPResultParser.h"

static NSString *const kSKClientVersion = @"1.0";



static NSString *const kKeySKClientCurrentSession = @"com.oursky.StatKit.kKeySKClientCurrentSession";

static NSString *const kKeySKClientIsNewUser = @"com.oursky.StatKit.kKeySKClientIsNewUser";

static NSString *const kKeySKClientPendingEvents = @"com.oursky.StatKit.kKeySKClientPendingEvents";
static NSString *const kKeySKClientPendingSessions = @"com.oursky.StatKit.kKeySKClientPendingSessions";


static NSString *const kKeySKClientEvents = @"events";

static NSString *const kKeySKClientDevice = @"device";
static NSString *const kKeySKClientDeviceID = @"device_id";
static NSString *const kKeySKClientDeviceAppID = @"app_id";
static NSString *const kKeySKClientDeviceCreateTimestamp = @"create_timestamp";
static NSString *const kKeySKClientDeviceLanguage = @"language";
static NSString *const kKeySKClientDeviceAppVersion = @"app_version";

static NSString *const kKeySKClientSessions = @"sessions";


@interface SKClient ()

@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) SKSession *currentSession;
@property (strong, nonatomic) NSDictionary *extras;

@property (strong, nonatomic) NSMutableArray *pendingEvents;
@property (strong, nonatomic) NSMutableArray *pendingSessions;

@property (strong, nonatomic) Reachability *hostReachability;
@property (strong, nonatomic) Reachability *wanReachability;

@property (strong, nonatomic) PublicIPRetriever *publicIPRetriever;

@end

@implementation SKClient

static SKClient *activeClient = nil;

+ (instancetype)shared
{
    static id shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

+ (void)setActiveClient:(SKClient*)client
{
    activeClient = client;
}

+ (instancetype)activeClient
{
    return activeClient;
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
{
    self = [self init];
    if (self)
    {
        _userDefaults = userDefaults;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSString *hostname = [self reachabilityTargetHost];
        if (hostname)
        {
            self.hostReachability = [Reachability reachabilityWithHostName:hostname];
            [self.hostReachability startNotifier];
        }
        
        self.wanReachability = [Reachability reachabilityForInternetConnection];
        [self.wanReachability startNotifier];
        
        self.publicIPRetriever = [[PublicIPRetriever alloc] init];
        [self.publicIPRetriever registerAPI:@"http://ip-api.com/line/?fields=query" withParser:[[SimpleIPResultParser alloc] init]];
        [self.publicIPRetriever registerAPI:@"https://wtfismyip.com/text" withParser:[[SimpleIPResultParser alloc] init]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)startSession
{
    if ([self isNewUser])
    {
        [self startNewUser];
    }
    
    [self submitLogIfNeeded];
    
    [self startNewSession];
    
    [self lookUpCurrentPublicIP];
}

- (void)addStatEvent:(SKEvent*)event
{
    [self addStatEvent:event sessionID:self.currentSession.id];
}

#pragma mark - protected methods

- (NSUInteger)pendingEventsCount
{
    return self.pendingEvents.count;
}

- (NSUInteger)pendingSessionsCount
{
    return self.pendingSessions.count;
}

- (NSString*)reachabilityTargetHost
{
    return nil;
}

- (BOOL)shouldSubmitLog
{
    return NO;
}

- (void)sendDataToServer:(NSData*)data
           resultHandler:(void(^)(BOOL success))resultHandler
{
    NSLog(@"subclass should implement this method for sending data to server");
}

#pragma mark - private methods


- (NSMutableArray*)pendingEvents
{
    if (!_pendingEvents)
    {
        NSArray *array = [self.userDefaults arrayForKey:kKeySKClientPendingEvents];
        if (!array)
        {
            array = @[];
            [self.userDefaults setObject:array forKey:kKeySKClientPendingEvents];
            [self.userDefaults synchronize];
        }
        _pendingEvents = [NSMutableArray arrayWithArray:array];
    }
    return _pendingEvents;
}

- (NSMutableArray*)pendingSessions
{
    if (!_pendingSessions)
    {
        NSArray *array = [self.userDefaults arrayForKey:kKeySKClientPendingSessions];
        if (!array)
        {
            array = @[];
            [self.userDefaults setObject:array forKey:kKeySKClientPendingSessions];
            [self.userDefaults synchronize];
        }
        _pendingSessions = [NSMutableArray arrayWithArray:array];
    }
    return _pendingSessions;
}


#pragma mark reachability

- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    if (curReach == self.hostReachability)
    {
        NetworkStatus status = [curReach currentReachabilityStatus];
        if (status != NotReachable)
        {
            [self submitLogIfNeeded];
        }
    }
    else if (curReach == self.wanReachability)
    {
        [self lookUpCurrentPublicIP];
    }
}

#pragma mark device info

- (dispatch_queue_t)workerQueue
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.oursky.StatKit.queue", 0);
    });
    return queue;
}

- (NSString*)deviceID
{
    static NSString* deviceID;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deviceID = [[[[UIDevice currentDevice] identifierForVendor] UUIDString] md5];
    });
    return deviceID;
}

- (BOOL)isNewUser
{
    id isNewUser = [self.userDefaults objectForKey:kKeySKClientIsNewUser];
    return isNewUser == nil || [isNewUser boolValue] == YES;
}

- (void)startNewUser
{
    [self.userDefaults setBool:NO forKey:kKeySKClientIsNewUser];
    [self.userDefaults setObject:@([[NSDate date] unixTimestamp]) forKey:kKeySKClientDeviceCreateTimestamp];
    [self.userDefaults synchronize];
}

#pragma mark session

- (NSString*)createSessionID
{
    return [[NSUUID UUID] UUIDString];
}

- (void)startNewSession
{
    NSDictionary *lastSession = [self.userDefaults dictionaryForKey:kKeySKClientCurrentSession];
    NSUInteger sessionCount = 0;
    
    if (lastSession)
    {
        SKSession *s = [SKSession sessionWithDictionary:lastSession];
        sessionCount = s.count + 1;
    }
    
    self.currentSession = [SKSession newSessionWithCount:sessionCount];
    
    [self.userDefaults setObject:self.currentSession.dictionary forKey:kKeySKClientCurrentSession];
    
    [self addPendingLog:self.currentSession toArray:self.pendingSessions userDefaultsKey:kKeySKClientPendingSessions completionHandler:nil];
}

- (void)lookUpCurrentPublicIP
{
    dispatch_async(self.workerQueue, ^{
        [self.publicIPRetriever lookupCurrentPublucIP:^(NSString *publucIP) {
            
            NSLog(@"current public IP: %@", publucIP);
            if (publucIP)
            {
                [self.currentSession setIPAddress:publucIP];
                [self.userDefaults setObject:self.currentSession.dictionary forKey:kKeySKClientCurrentSession];
                [self updatePendingSession:self.currentSession];
            }
            
        }];
    });
}

#pragma mark log

- (void)addPendingLog:(id<SKData>)log
              toArray:(NSMutableArray*)array
      userDefaultsKey:(NSString*)arrayID
    completionHandler:(void(^)(void))completionHandler
{
    dispatch_async(self.workerQueue, ^{
        
        [array addObject:[log dictionary]];
        
        [self.userDefaults setObject:array forKey:arrayID];
        [self.userDefaults synchronize];
        
        if (completionHandler) completionHandler();
        
    });
}

- (void)updatePendingSession:(SKSession*)session
{
    dispatch_async([self workerQueue], ^{
        
        NSDictionary *sessionToUpdate = nil;
        for (NSDictionary *d in self.pendingSessions) {
            
            SKSession *s = [SKSession sessionWithDictionary:d];
            if ([s.id isEqualToString:session.id])
            {
                sessionToUpdate = d;
                break;
            }
        }
        
        if (sessionToUpdate)
        {
            [self.pendingSessions removeObject:sessionToUpdate];
            [self.pendingSessions addObject:session.dictionary];
        }
        
    });
}

- (void)submitLogIfNeeded
{
    dispatch_async(self.workerQueue, ^{
        
        if (![self shouldSubmitLog]) return;
        
        NSArray *events = [self.pendingEvents copy];
        NSArray *sessions = [self.pendingSessions copy];
        
        [self.pendingEvents removeAllObjects];
        [self.pendingSessions removeAllObjects];
        
        [self.userDefaults setObject:self.pendingEvents forKey:kKeySKClientPendingEvents];
        [self.userDefaults setObject:self.pendingSessions forKey:kKeySKClientPendingSessions];
        [self.userDefaults synchronize];
        
        NSDictionary *deviceInfo = [self prepareDeviceInfo];
        NSDictionary *dict = [self prepareDictionaryWithDeviceInfo:deviceInfo events:events sessions:sessions];
        NSData *data = [self encodeJSON:dict];
        
        __block BOOL didCallResultHandler = NO;
        
        [self sendDataToServer:data resultHandler:^(BOOL success) {
            dispatch_async(self.workerQueue, ^{
                
                if (didCallResultHandler)
                {
                    NSLog(@"result handler has been called, ignored");
                    return;
                }
                
                didCallResultHandler = YES;
                
                if (!success)
                {
                    NSLog(@"failed to submit");
                    [self.pendingEvents addObjectsFromArray:events];
                    [self.pendingSessions addObjectsFromArray:sessions];
                    
                    [self.userDefaults setObject:self.pendingEvents forKey:kKeySKClientPendingEvents];
                    [self.userDefaults setObject:self.pendingSessions forKey:kKeySKClientPendingSessions];
                    [self.userDefaults synchronize];
                }

            });
        }];
        
    });
    
}

- (void)addStatEvent:(SKEvent*)event
           sessionID:(NSString*)sessionID
{
    if (sessionID)
    {
        [event setSessionID:sessionID];
    }
    
    __weak id weakSelf = self;
    
    [self addPendingLog:event toArray:self.pendingEvents userDefaultsKey:kKeySKClientPendingEvents completionHandler:^{
        [weakSelf submitLogIfNeeded];
    }];
}


#pragma mark prepare data

- (NSDictionary*)prepareDeviceInfo
{
    return @{ kKeySKClientDeviceID : [self deviceID],
              kKeySKClientDeviceAppID : [[NSBundle mainBundle] bundleIdentifier],
              kKeySKClientDeviceCreateTimestamp : [self.userDefaults objectForKey:kKeySKClientDeviceCreateTimestamp],
              kKeySKClientDeviceLanguage : [[NSLocale currentLocale] localeIdentifier],
              kKeySKClientDeviceAppVersion : [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] };
}

- (NSDictionary*)prepareDictionaryWithDeviceInfo:(NSDictionary*)deviceInfo
                                          events:(NSArray*)events
                                        sessions:(NSArray*)sessions
{
    events = events == nil ? @[] : events;
    sessions = sessions == nil ? @[] : sessions;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{ kKeySKClientEvents : events,
                                                                                 kKeySKClientDevice : deviceInfo,
                                                                                 kKeySKClientSessions : sessions }];
    
    return dict;
}

- (NSData *)encodeJSON:(id)obj
{
    return [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
}

@end
