//
//  CLIParser.m
//  RegEdit
//
//  Created by Keith Lee on 5/13/13.
//  Copyright (c) 2013 Keith Lee. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//   1. Redistributions of source code must retain the above copyright notice, this list of
//      conditions and the following disclaimer.
//
//   2. Redistributions in binary form must reproduce the above copyright notice, this list
//      of conditions and the following disclaimer in the documentation and/or other materials
//      provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY Keith Lee ''AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Keith Lee OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Keith Lee.

#import "CLIParser.h"
#import "RegEditConstants.h"

NSString *HelpCommand =
@"\n  RegEdit -n [Hex initial register settings] -b [byte number] -v [hex byte value]";
NSString *HelpDesc = @"\n\nNAME\n  RegEdit - Get/set selected byte of a register.";
NSString *HelpSynopsis = @"\n\nSYNOPSIS";
NSString *HelpOptions = @"\n\nOPTIONS";
NSString *HelpRegValue = @"\n  -n\tThe initial register settings.";
NSString *HelpRegByte = @"\n  -b\tThe byte to retrieve from the register.";
NSString *HelpByteValue = @"\n  -v\tA value to set for the selected register byte.";

@implementation CLIParser

// Private instance variables
{
  const char **argValues;
  int argCount;
}

- (id) initWithCount:(int)argc arguments:(const char *[])argv
{
  if ((self = [super init]))
  {
    argValues = argv;
    argCount = argc;
  }
  return self;
}

- (BOOL) parseWithRegister:(uint32 *)registerValue
                byteNumber:(NSInteger *)byteN
                 doSetByte:(BOOL *)doSet
                 byteValue:(unsigned int *)byteValue
                     error:(NSError **)anError
{
  // Retrieve command line arguments using NSUserDefaults
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *numberString = [defaults stringForKey:@"n"];
  NSString *byteString = [defaults stringForKey:@"b"];
  NSString *valueString = [defaults stringForKey:@"v"];
  
  // Display help message if register value or byte number not provided
  if (!numberString || !byteString)
  {
    NSString *help = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",
                      HelpDesc, HelpSynopsis, HelpCommand,
                      HelpOptions, HelpRegValue, HelpRegByte,
                      HelpByteValue];
    printf("%s\n", [help UTF8String]);
    return NO;
  }
  
  // Scan input register value
  NSScanner *scanner = [NSScanner scannerWithString:numberString];
  if (!numberString ||
      ([numberString length] == 0) ||
      ([numberString length] > kRegisterSize*2) ||
      ![scanner scanHexInt:registerValue])
  {
    // Create error and return NO
    if (anError != NULL)
    {
      NSString *msg =
      [NSString stringWithFormat:
       @"ERROR!, Register value must be from 1-%ld hexadecimal characters",
       kRegisterSize*2];
      NSString *description = NSLocalizedString(msg, @"");
      NSDictionary *info = @{NSLocalizedDescriptionKey:description};
      int errorCode = 1;
      *anError = [NSError errorWithDomain:@"CustomErrorDomain"
                                     code:errorCode
                                 userInfo:info];
    }
    return NO;
  }
  
  // Scan input register byte number
  scanner = [NSScanner scannerWithString:byteString];
  if (!byteString ||
      ([byteString length] == 0) ||
      [scanner scanInteger:byteN])
  {
    unsigned int numberLength = (unsigned int)(ceil([numberString length] * 0.5));
    if ((*byteN < 0) || (*byteN > (numberLength - 1)))
    {
      // Create error and return NO
      if (anError != NULL)
      {
        NSString *msg = [NSString stringWithFormat:
                         @"ERROR!, Register byte number must be from 0-%d",
                         numberLength-1];
        NSString *description = NSLocalizedString(msg, @"");
        NSDictionary *info = @{NSLocalizedDescriptionKey:description};
        int errorCode = 2;
        *anError = [NSError errorWithDomain:@"CustomErrorDomain"
                                       code:errorCode
                                   userInfo:info];
      }
      return NO;
    }
  }
  
  // Scan input value to set register byte
  if (valueString)
  {
    *doSet = YES;
    scanner = [NSScanner scannerWithString:valueString];
    if ([scanner scanHexInt:byteValue])
    {
      if (*byteValue > UCHAR_MAX)
      {
        if (anError != NULL)
        {
          NSString *msg =
          [NSString stringWithFormat:
           @"ERROR!, Register byte value must be 1-2 hexadecimal characters"];
          NSString *description = NSLocalizedString(msg, @"");
          NSDictionary *info = @{NSLocalizedDescriptionKey:description};
          int errorCode = 3;
          *anError = [NSError errorWithDomain:@"CustomErrorDomain"
                                         code:errorCode
                                     userInfo:info];
        }
        return NO;
      }
    }
  }
  
  return YES;
}

@end
