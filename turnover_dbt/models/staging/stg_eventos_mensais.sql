select
    id_funcionario,
    mes_referencia,
    meses_desde_admissao,
    salario_no_mes,
    nota_desempenho,
    faltas_mes,
    horas_extras_mes,
    foi_promovido
from {{ source('bronze', 'raw_eventos') }}
