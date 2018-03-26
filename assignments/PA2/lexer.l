%{
    \DIGIT      [0-9]
%}
%%
{DIGIT} {
    cool_yylval.symbol = inttable.add_string(yytext);
    return DIGIT_TOKEN;
}

%%
