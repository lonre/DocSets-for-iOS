//
//  DictHelper.m
//  DocSets
//
//  Created by Wang Long on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LRDictHelper.h"
#import "FMDatabase.h"

static NSString* const kDBPath = @"dict.db";

@implementation LRDictHelper

+ (NSArray *)singularInflections {
  NSMutableArray *singulars = [NSMutableArray arrayWithCapacity:41];
  [singulars addObject:[NSArray arrayWithObjects:@"s$", @"", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(n)ews$", @"$1ews", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"([ti])a$", @"$1um", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$", @"$1$2sis", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(^analy)ses$", @"$1sis", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"([^f])ves$", @"$1fe", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(hive)s$", @"$1", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(tive)s$", @"$1", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"([lr])ves$", @"$1f", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"([^aeiouy]|qu)ies$", @"$1y", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(s)eries$", @"$1eries", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(m)ovies$", @"$1ovie", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(x|ch|ss|sh)es$", @"$1", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(m|l)ice$", @"$1ouse", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(bus)es$", @"$1", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(o)es$", @"$1", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(shoe)s$", @"$1", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(cris|ax|test)es$", @"$1is", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(octop|vir)i$", @"$1us", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(alias|status)es$", @"$1", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"^(ox)en/i", @"$1", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(vert|ind)ices$", @"$1ex", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(matr)ices$", @"$1ix", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(quiz)zes$", @"$1", nil]];
  [singulars addObject:[NSArray arrayWithObjects:@"(database)s$", @"$1", nil]];
  return [NSArray arrayWithArray:singulars];
}

+ (NSString *)singularize:(NSString *)word {
  NSMutableString *result = [NSMutableString stringWithString:word];
  NSRegularExpression *regex;
  for (NSArray *rule in [self singularInflections]) {
    regex = [NSRegularExpression regularExpressionWithPattern:[rule objectAtIndex:0] options:NSRegularExpressionCaseInsensitive error:NULL];
    NSUInteger count = [regex replaceMatchesInString:result options:0 range:NSMakeRange(0, [result length]) withTemplate:[rule objectAtIndex:1]];
    if (count > 0) break;
  }
  return [NSString stringWithString:result];
}

+ (NSString *)prettyDefinition:(NSString *)definition {
  definition = [definition stringByReplacingOccurrencesOfString:@"_L" withString:@"  || "];
  definition = [definition stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
  return definition;
}

+ (FMDatabase *)openDictDababase {
  NSString *fullDBPath = [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] objectAtIndex:0] URLByAppendingPathComponent:kDBPath] path];
  if (![[NSFileManager defaultManager] fileExistsAtPath:fullDBPath]) {
    NSLog(@"no dict db found!");
    return nil; 
  }
  FMDatabase *db = [FMDatabase databaseWithPath:fullDBPath];
  return [db open]?db:nil;
}

+ (NSString *)definitionForWord:(NSString *)word {
  NSString *theWord = word.lowercaseString;
  FMDatabase *db = [LRDictHelper openDictDababase];
  if (db == nil) return nil;
  NSString *sql = @"select definition from wiktionary w where w.word = '%@'";
  FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:sql, theWord]];
  if ([rs next]) {
    NSString *definition = [rs stringForColumnIndex:0];
    return [self prettyDefinition:definition];
  } else {
    rs = [db executeQuery:[NSString stringWithFormat:sql, [LRDictHelper singularize:word]]];
    if ([rs next]) {
      NSString *definition = [rs stringForColumnIndex:0];
      return [self prettyDefinition:definition];
    }
  }
  return nil;
}

@end
