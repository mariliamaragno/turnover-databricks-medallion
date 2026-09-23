with eventos as (
    select * from {{ ref('stg_eventos_mensais') }}
),

com_janela as (
    select
        id_funcionario,
        mes_referencia,
        meses_desde_admissao,
        salario_no_mes,
        nota_desempenho,
        faltas_mes,
        horas_extras_mes,
        foi_promovido,

        avg(nota_desempenho) over (
            partition by id_funcionario
            order by meses_desde_admissao
            rows between 5 preceding and current row
        ) as media_desempenho_6m,

        avg(faltas_mes) over (
            partition by id_funcionario
            order by meses_desde_admissao
            rows between 5 preceding and current row
        ) as media_faltas_6m,

        sum(horas_extras_mes) over (
            partition by id_funcionario
            order by meses_desde_admissao
            rows between 5 preceding and current row
        ) as total_horas_extras_6m,

        sum(case when foi_promovido then 1 else 0 end) over (
            partition by id_funcionario
            order by meses_desde_admissao
        ) as qtd_promocoes_acumulado,

        row_number() over (
            partition by id_funcionario
            order by meses_desde_admissao desc
        ) as rn

    from eventos
)

select * from com_janela where rn = 1
