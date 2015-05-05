//
//  QZBLoggingConfig.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 05/05/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBLoggingConfig.h"


#ifdef DEBUG
int const ddLogLevel = DDLogLevelVerbose;
#else
int const ddLogLevel = DDLogLevelError;
#endif
