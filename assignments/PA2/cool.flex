/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>
#include <string>
using namespace std;

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

int comment_nest = 0;


/*
 *  Add Your own definitions here
    STRING      [\"][^\"]*[\"]
 */



%}

ASSIGN      <-
DARROW      =>
LE          <=
INTEGER     [0-9]+
TYPEID      [A-Z][A-Za-z0-9_]*
OBJID       [a-z][A-Za-z0-9_]*
ID          [A-Za-z0-9_]*
WHITESPACE  [ \t\r\f\v]
NEWLINE     [\n]
LINECOMMENT "--".*
TRUE        "t"(?i:"rue")
FALSE       "f"(?i:"alse")


%x COMMENT
%x STRING
%x ENDSTRING

%%

"*)"    {
    yylval.error_msg = "Unmatched *)";
    return ERROR;

}

(?i:"CLASS")      { return CLASS;}
(?i:"ELSE")       { return ELSE;}
(?i:"FI")         { return FI;}
(?i:"IF")         { return IF;}
(?i:"IN")         { return IN;}
(?i:"INHERITS")   { return INHERITS;}
(?i:"LET")        { return LET;}
(?i:"LOOP")       { return LOOP;}
(?i:"POOL")       { return POOL;}
(?i:"THEN")       { return THEN;}
(?i:"WHILE")      { return WHILE;}
(?i:"CASE")       { return CASE;}
(?i:"ESAC")       { return ESAC;}
(?i:"OF")         { return OF;}
(?i:"NEW")        { return NEW;}
(?i:"NOT")        { return NOT;}
(?i:"ISVOID")     { return ISVOID;}
{LE}              { return LE;}
{ASSIGN}          { return ASSIGN;}
{DARROW}          { return DARROW;}
"+"     { return '+';}
"/"     { return '/';}
"-"     { return '-';} 
"*"     { return '*';}
"="     { return '=';}
"<"     { return '<';}
"."     { return '.';}
"~"     { return '~';}
","     { return ',';} 
";"     { return ';';}
":"     { return ':';}
"("     { return '(';}
")"     { return ')';}
"@"     { return '@';}
"{"     { return '{';}
"}"     { return '}';}

{WHITESPACE}      ;
{NEWLINE}         {curr_lineno++;}

{TRUE} {
                    cool_yylval.boolean = true;
                    return BOOL_CONST;
}

{FALSE} {  
                    cool_yylval.boolean = false;
                    return BOOL_CONST;
}

{INTEGER}   {
    cool_yylval.symbol = inttable.add_int(atoi(yytext));
    return INT_CONST;
}

{TYPEID}    {
    cool_yylval.symbol = idtable.add_string(yytext);
    return TYPEID;
}

{OBJID}    {
    cool_yylval.symbol = idtable.add_string(yytext);
    return OBJECTID;
}


{LINECOMMENT}   ;
 
"(*"            { BEGIN(COMMENT); }

<COMMENT>{
    "(*"        { comment_nest++; }
    "*"+")"     { if(comment_nest) --comment_nest;
                  else{
                      BEGIN(INITIAL);
                  }
                }
    <<EOF>>     { cool_yylval.error_msg="EOF in comment"; 
                  BEGIN(INITIAL);
                  return ERROR;
                }
    \n          {curr_lineno++;}
    .           ;
}


"\""            { 
                  string_buf_ptr = string_buf;
                  BEGIN(STRING);
}

<STRING>{
    "\""        { 
                    if(string_buf_ptr - string_buf == MAX_STR_CONST){
                        cool_yylval.error_msg="String constant too long";
                        BEGIN(ENDSTRING);
                        return ERROR;
                    }else{ 
                        *string_buf_ptr = '\0';
                        // printf("String size: %d\n", string_buf_ptr - string_buf); 
                        cool_yylval.symbol = stringtable.add_string(string_buf, string_buf_ptr - string_buf);
                        BEGIN(INITIAL); 
                        return STR_CONST; 
                    }
                }
    <<EOF>>     { cool_yylval.error_msg="EOF in string"; 
                  BEGIN(INITIAL);
                  return ERROR;
                }
    "\\\""       { if(string_buf_ptr - string_buf == MAX_STR_CONST){
                        cool_yylval.error_msg="String constant too long";
                        BEGIN(ENDSTRING);
                        return ERROR;
                  }else{ 
                        *string_buf_ptr = '"'; 
                        string_buf_ptr++; 
                  }
                }
    "\\t"       { if(string_buf_ptr - string_buf == MAX_STR_CONST){
                        cool_yylval.error_msg="String constant too long";
                        BEGIN(ENDSTRING);
                        return ERROR;
                  }else{ 
                        *string_buf_ptr = '\t'; 
                        string_buf_ptr++; 
                  }
                }
    "\\f"       { if(string_buf_ptr - string_buf == MAX_STR_CONST){
                        cool_yylval.error_msg="String constant too long";
                        BEGIN(ENDSTRING);
                        return ERROR;
                  }else{ 
                        *string_buf_ptr = '\f'; 
                        string_buf_ptr++; 
                  }
                }
    "\\b"       { if(string_buf_ptr - string_buf == MAX_STR_CONST){
                        cool_yylval.error_msg="String constant too long";
                        BEGIN(ENDSTRING);
                        return ERROR;
                  }else{ 
                        *string_buf_ptr = '\b'; 
                        string_buf_ptr++; 
                  }
                }
    "\\r"       { if(string_buf_ptr - string_buf == MAX_STR_CONST){
                        cool_yylval.error_msg="String constant too long";
                        BEGIN(ENDSTRING);
                        return ERROR;
                  }else{ 
                        *string_buf_ptr = '\r'; 
                        string_buf_ptr++; 
                  }
                }
    "\\n"       { if(string_buf_ptr - string_buf == MAX_STR_CONST){
                        cool_yylval.error_msg="String constant too long";
                        BEGIN(ENDSTRING);
                        return ERROR;
                  }else{
                        curr_lineno++;
                        *string_buf_ptr = '\n'; 
                        string_buf_ptr++; 
                  }
                }
    "\\0"       { if(string_buf_ptr - string_buf == MAX_STR_CONST){
                        cool_yylval.error_msg="String constant too long";
                        BEGIN(ENDSTRING);
                        return ERROR;
                  }else{ 
                        *string_buf_ptr = '0'; 
                        string_buf_ptr++; 
                  }
                }
    "\\\n"      {
                    if(string_buf_ptr - string_buf == MAX_STR_CONST){
                        cool_yylval.error_msg="String constant too long";
                        BEGIN(ENDSTRING);
                        return ERROR;
                    }else{
                        curr_lineno++; 
                        *string_buf_ptr = '\n';
                        string_buf_ptr++; 
                    }
                }
    \n          { 
                  curr_lineno++;
                  cool_yylval.error_msg="Unterminated string constant";
                  BEGIN(INITIAL);
                  return ERROR;

                }
    \0        {
                     cool_yylval.error_msg="String contains null character";
                     BEGIN(ENDSTRING);
                     return ERROR;
                }
    "\\\0"        {
                     cool_yylval.error_msg="String contains escaped null character.";
                     BEGIN(ENDSTRING);
                     return ERROR;
                }
    "\\".       { if(string_buf_ptr - string_buf == MAX_STR_CONST){
                        cool_yylval.error_msg="String constant too long";
                        BEGIN(ENDSTRING);
                        return ERROR;
                  }else{ 
                        *string_buf_ptr = yytext[1]; 
                        string_buf_ptr++; 
                  }
                }
    .           {
                  if(string_buf_ptr - string_buf == MAX_STR_CONST){
                        cool_yylval.error_msg="String constant too long";
                        BEGIN(ENDSTRING);
                        return ERROR;
                  }else{
                        *string_buf_ptr = yytext[0];
                        string_buf_ptr++;
                  }
                }
}

<ENDSTRING>{
    "\""    {BEGIN(INITIAL);}
    \n      {BEGIN(INITIAL);}
    .       {;}
}

.  {
    cool_yylval.error_msg = yytext;
    return ERROR;
}

%%
