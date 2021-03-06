//
//  NSArray+Functional.m
//  Cacao
//
//    Copyright 2010, 2011, Joubert Nel. All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without modification, are
//    permitted provided that the following conditions are met:
//
//    1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
//    2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other materials
//    provided with the distribution.
//
//    THIS SOFTWARE IS PROVIDED BY JOUBERT NEL "AS IS'' AND ANY EXPRESS OR IMPLIED
//    WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//    FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JOUBERT NEL OR
//    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//    ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//    The views and conclusions contained in the software and documentation are those of the
//    authors and should not be interpreted as representing official policies, either expressed
//    or implied, of Joubert Nel.

#import "NSArray+Functional.h"


@implementation NSArray (Functional)

- (NSArray *)map:(id (^)(id object))block 
{
    __block NSMutableArray * result = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj)];
    }];
    
    return [NSArray arrayWithArray:result];
}

- (NSArray *)popFirstInto:(NSObject **)firstItem
{
    NSObject * firstObject = [self objectAtIndex:0];
    *firstItem = firstObject;
    NSRange rest;
    rest.location = 1;
    rest.length = [self count] - 1;
    return [self subarrayWithRange:rest];
}

- (NSDictionary *)dictionaryFromKeysAndValues
{
    NSUInteger kvCount = [self count] / 2;
    id keys[kvCount];
    id vals[kvCount];

    NSUInteger i = 0;
    while (i < kvCount ) {
        NSUInteger keyIndex = i*2;
        NSUInteger valIndex = keyIndex + 1;
        
        keys[i] = [self objectAtIndex:keyIndex];
        vals[i] = [self objectAtIndex:valIndex];
        i++;
    }

    return [NSDictionary dictionaryWithObjects:vals forKeys:keys count:kvCount];
}

@end
