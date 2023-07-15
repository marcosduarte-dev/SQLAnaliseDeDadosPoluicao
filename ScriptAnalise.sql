# Script realizado para responder perguntas sobre os índices de poluição do ar
# Marcos Pedroso Duarte
# Github: https://github.com/marcosduarte-dev

# 1- Quais poluentes foram considerados na pesquisa?

SELECT DISTINCT pollutant FROM tb_global_qualidade_ar;

# 2- Qual foi a média de poluição ao longo do tempo provocada pelo poluente ground-level ozone (o3)?
SELECT country AS pais,
       CAST(timestamp AS DATE) AS data_coleta,
       ROUND(AVG(value) OVER(PARTITION BY country ORDER BY CAST(timestamp AS DATE)), 2) AS media_valor_poluicao
FROM TB_GLOBAL_QUALIDADE_AR
WHERE pollutant = 'o3'
ORDER BY country, data_coleta;

# 3- Qual foi a média de poluição causada pelo poluente ground-level ozone (o3) por país medida em µg/m³ (microgramas por metro cúbico)?
SELECT country AS pais,
       ROUND(AVG(value), 2) AS media_poluicao
FROM TB_GLOBAL_QUALIDADE_AR
WHERE pollutant = 'o3'
AND unit = 'µg/m³'
GROUP BY country
ORDER BY country;

# 4- Considerando o resultado anterior, qual país teve maior índice de poluição geral por o3, Itália (IT) ou Espanha (ES)? Por quê?
SELECT country AS pais, 
       ROUND(AVG(value),2) AS media_poluicao, 
       STDDEV(value) AS desvio_padrao, 
       MAX(value) AS valor_maximo, 
       MIN(value) AS valor_minimo,
       (STDDEV(value) / ROUND(AVG(value),2)) * 100 AS cv
FROM TB_GLOBAL_QUALIDADE_AR
WHERE pollutant = 'o3'
AND unit = 'µg/m³'
AND country IN ('IT', 'ES') 
GROUP BY country
ORDER BY media_poluicao ASC;

# Conclusão: Embora o CV da Espanha seja muito maior, a média da Itália é muito alta, com os pontos de dados mais próximos da média.
# Os 2 países tem um alto índice de poluição geral por o3
# A Itália apresenta maior índice de poluição geral, pois a média é alta e os pontos de dados estão mais próximos da média.

# 5- Quais localidades e países tiveram média de poluição em 2020 superior a 100 µg/m³ para o poluente fine particulate matter (pm25)?
SELECT coalesce(location, 'Total') as location, 
       coalesce(country, 'Total') as country,
AVG(value) as Media
FROM tb_global_qualidade_ar
WHERE pollutant = 'pm25'
AND YEAR(timestamp) = 2020
AND unit = 'µg/m³'
GROUP BY location, country WITH ROLLUP
HAVING Media > 100