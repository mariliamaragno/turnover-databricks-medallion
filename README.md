# Previsão de Turnover — Arquitetura Medalhão com Databricks + dbt

Projeto de portfólio simulando um pipeline de engenharia de dados de RH, do dado bruto a uma tabela de features pronta para análise e Machine Learning, seguindo a arquitetura medalhão (Bronze → Silver → Gold) sobre Databricks.

## Objetivo

Demonstrar competência em engenharia de dados distribuída (PySpark) e modelagem analítica versionada (dbt) sobre uma plataforma Lakehouse — construindo um pipeline reprodutível que serve tanto análise de negócio quanto Machine Learning como consumidores finais.

## Stack

- **Faker + PySpark** — geração de dados sintéticos (funcionários, eventos mensais, desligamentos), processados de forma distribuída
- **Delta Lake** — formato de armazenamento das tabelas Bronze
- **dbt (dbt-databricks)** — transformação e modelagem em camadas (Silver, Gold)
- **Databricks (Community Edition / Free)** — plataforma de execução, notebooks e SQL Warehouse
- **PySpark MLlib** — modelo de classificação (Random Forest) para previsão de turnover

## Arquitetura Medalhão

\`\`\`
Bronze (raw)              Silver (staging)            Gold (marts)
──────────────────        ──────────────────          ──────────────────
raw_funcionarios      →    stg_funcionarios       →
raw_eventos           →    stg_eventos_mensais    →    int_eventos_com_tendencia
raw_desligamentos     →    stg_desligamentos      →    (window functions SQL)
                                                              ↓
                                                        mart_features_turnover
\`\`\`

- **Bronze**: dados sintéticos gerados em notebook PySpark, salvos como tabelas Delta — representa o dado "como chegou", sem tratamento
- **Silver**: models dbt de limpeza e padronização, um por tabela de origem
- **Gold**: \`int_eventos_com_tendencia\` calcula métricas de tendência (média de desempenho e faltas nos últimos 6 meses, promoções acumuladas) via **window functions em SQL**; \`mart_features_turnover\` une essas métricas com dados cadastrais e o status de desligamento, formando a tabela final de features

## Nota sobre PySpark vs. SQL

A lógica de tendência (janela dos últimos 6 meses) foi implementada duas vezes, de propósito: primeiro em **PySpark** (\`Window.partitionBy().orderBy().rowsBetween()\`), depois em **SQL puro** dentro do dbt (\`partition by ... order by ... rows between 5 preceding and current row\`). São a mesma operação, expressa em duas sintaxes — decisão deliberada para demonstrar fluência nas duas formas de trabalhar com window functions, comuns em vagas de Analytics/Data Engineer.

## Qualidade de dados

5 testes automatizados no dbt cobrindo:
- Unicidade e não-nulidade do identificador de funcionário
- Valores aceitos em colunas categóricas (área, senioridade, flag de saída)
- Faixa plausível para a métrica de desempenho (\`dbt_utils.accepted_range\`)

## Modelo de Machine Learning (camada de consumo)

Como demonstração de que a camada Gold serve como base tanto para análise quanto para ciência de dados, um notebook separado treina um classificador Random Forest (PySpark MLlib) sobre \`mart_features_turnover\`, prevendo a probabilidade de desligamento. O treinamento evidenciou um problema clássico de **classes desbalanceadas** (~17% de turnover) — corrigido com ponderação de classe (\`weightCol\`) no treinamento.

## Como rodar localmente (camada dbt)

\`\`\`bash
python3 -m venv venv && source venv/bin/activate
pip install dbt-databricks

cd turnover_dbt
dbt deps
dbt run
dbt test
\`\`\`

> Requer um workspace Databricks ativo com as tabelas Bronze já carregadas (ver notebook \`01_gerar_dados_sinteticos\`, mantido separadamente no workspace Databricks).

## Roadmap

- [x] Geração de dados sintéticos com Faker, processados via PySpark
- [x] Camada Bronze (tabelas Delta)
- [x] Camada Silver (dbt staging)
- [x] Camada Gold (window functions SQL, mart de features)
- [x] Testes de qualidade de dados
- [x] Modelo de Machine Learning (Random Forest, PySpark MLlib) como consumidor da camada Gold
- [ ] Orquestração via Databricks Workflows

---

Projeto desenvolvido por [Marília Maragno](https://www.linkedin.com/in/mariliamaragno/) como parte de estudo aplicado em engenharia de dados.
