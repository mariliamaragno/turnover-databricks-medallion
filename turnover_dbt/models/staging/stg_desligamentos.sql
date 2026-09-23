select
    id_funcionario,
    data_desligamento,
    tipo_desligamento
from {{ source('bronze', 'raw_desligamentos') }}
