unit QuoteTimeSQL;

interface

const
  Const_Sql_Mine = 'C_HQ_KINFOMINE(#InnerCode,0)';
  Const_Sql_Trade = 'C_HQ_TIMEMAIN_DEALPOINT(#InnerCode)';
  Const_Sql_Trade_New =
    'C_HQ_TIMEMAIN_DEALPOINT_NEW([#FundInnerCodes],#InnerCode)';

  Const_Sql_PointData = 'SELECT X.NBBM AS innercode, '
      + ' CASE '
      + '      WHEN INSTR( CAST ( X.deal_time AS varchar ) , ''.'' ) - 1 = 5 THEN SUBSTR( CAST ( X.deal_time AS varchar ) , 1, 3 ) '
      + '     WHEN INSTR( CAST ( X.deal_time AS varchar ) , ''.'' ) - 1 = 6 THEN SUBSTR( CAST ( X.deal_time AS varchar ) , 1, 4 ) '
      + ' END AS deal_time, '
      + ' X.account_name AS account_name, '
      + ' X.account_code AS account_code, '
      + ' X.entrust_direction AS entrust_direction, '
      + ' sum( X.deal_amount ) AS deal_amount, '
      + ' sum( X.deal_balance ) AS deal_balance, '
      + ' sum( X.deal_balance ) / NULLIF( sum( X.deal_amount ) , 0 )  deal_price '
  + ' FROM ( '
  + ' SELECT a.NBBM, '
  + '         b.deal_time, '
  + '         c.account_name, '
  + '         c.account_code, '
  + '         b.stock_code, '
  + '         b.entrust_direction, '
  + '         b.deal_amount, '
  + '         b.deal_price, '
  + '         b.deal_balance '
  + '    FROM StockInfo a '
  + '         JOIN Transactions b '
  + '           ON a.NBBM = #InnerCode '
  + '  AND '
  + '  a.ZQSC = b.market_no '
  + '  AND '
  + '  a.GPDM = b.stock_code '
  + '  AND '
  + '  b.entrust_direction IN ( 1, 2 ) '
  + '         JOIN Account c '
  + '           ON b.account_code = c.account_code '
+ ' ) '
+ ' X '
+ ' GROUP BY substr( CAST ( X.deal_time AS varchar ) , 1, 4 ), '
+ '          X.account_name, '
+ '          X.entrust_direction ';

  Const_Sql_ReplaceStr_InnerCode = '#InnerCode';
  Const_Sql_ReplaceStr_FundInnerCodes = '#FundInnerCodes';

implementation

end.
