select
    id_funcionario,
    nome,
    area,
    senioridade,
    cidade,
    data_admissao,
    salario_inicial
from {{ source('bronze', 'raw_funcionarios') }}
