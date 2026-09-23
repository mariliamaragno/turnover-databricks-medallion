with funcionarios as (
    select * from {{ ref('stg_funcionarios') }}
),

tendencias as (
    select * from {{ ref('int_eventos_com_tendencia') }}
),

desligamentos as (
    select
        id_funcionario,
        1 as saiu
    from {{ ref('stg_desligamentos') }}
),

final as (
    select
        f.id_funcionario,
        f.area,
        f.senioridade,
        f.cidade,
        f.salario_inicial,
        t.salario_no_mes,
        t.meses_desde_admissao as tempo_de_casa_meses,
        t.media_desempenho_6m,
        t.media_faltas_6m,
        t.total_horas_extras_6m,
        t.qtd_promocoes_acumulado,
        coalesce(d.saiu, 0) as saiu
    from funcionarios f
    inner join tendencias t on f.id_funcionario = t.id_funcionario
    left join desligamentos d on f.id_funcionario = d.id_funcionario
)

select * from final
