# MySQL

Estudos gerais do banco de dados mysql


## DBA

Database Administrator, ou o Administrador de Banco de Dados. É o profissional responsável por gerenciar, manter e garantir a integridade, segurança e desempenho dos bancos de dados de uma organização. Principais responsabilidades de um DBA incluem:
- Avaliação do ambiente tecnológico
- Gestão de acessos
- Otimização de performance
- Gestão de backup/armazenamento
- Monitoramento e configurações
- Administração de acessos da função de cada usuário


## Tuning

Otimização do ambiente MySQL visando melhora de performance, aprimorando o desempenho e eficiência do mesmo, de forma que o banco de dados possa lidar com cargas de trabalho maiores e responder mais rapidamente às consultas.

### Tipos de Tuning

- Trabalhando com os banco de dados e índices de tabelas
- Através de variáveis internas do MySQL, chamadas de MySQL de Tuning
- Através de Hardware e SO

### Tuning de Hardware

É necessário sempre considerar sistemas operacionais 64bits, porque o MySQL consume muita memória RAM, e sistemas 32bits limitam o uso de memória a 2.4GB/processo.

Configuração de RAM em uso pelo software pode ser configurada através de variáveis internas do MySQL, o ideal é disponibilizar o máximo de 50% da memória RAM existente no servidor para o MySQL. Por exemplo, em um servidor com 32GB de RAM, o MySQL pode ser configurado para usar até 16GB.

O tipo de leitura do disco "IO" difere em velocidade de acordo com onde os dados estão armazenados, sendo os mais rápidos os discos SSD, seguido por discos SAS e por último os discos SATA. O ideal é sempre utilizar discos SSD para armazenamento dos dados do MySQL. 


#### Tuning na Nuvem

É muito usado atualmente, e com isso temos uma preocupação menor com o Tuning de Hardware, pois os provedores de nuvem já oferecem máquinas virtuais otimizadas para bancos de dados, com configurações de CPU, RAM e armazenamento ajustadas, além de proprocionar a ampliação lógica dos recursos conforme a demanda.


### Variáveis de sistema

São variáveis declaradas na inicialização do sistema ambiente do MySQL, e elas definem tanto limites do banco de dados como parâmetros do servidor, como por exemplo, a porta de comunicação, o diretório de armazenamento dos dados, o limite máximo de conexões entre cliente e servidor, entre outros.

São mais de 250 variáveis de sistema disponíveis, e é necessário conhecer as principais para realizar o Tuning do MySQL. A cada nova versão do MySQL, novas variáveis são adicionadas, e algumas são depreciadas, então é importante sempre consultar a documentação oficial do MySQL para obter informações atualizadas sobre as variáveis de sistema disponíveis e suas funcionalidades.

O comando para visualizar a situação das variáveis de sistema é:

```sql
SHOW STATUS;
```

Existem dois tipos de variáveis de sistema a **Global** e a **Session**. As variáveis globais afetam todo o servidor MySQL e são aplicadas a todas as conexões, enquanto as variáveis de sessão afetam apenas a conexão atual onde a variável foi definida.

Podem ser dinâmicas ou não. As variáveis dinâmicas podem ser alteradas em tempo de execução sem a necessidade de reiniciar o servidor MySQL, enquanto as variáveis não dinâmicas exigem uma reinicialização do servidor ou criação de uma nova sessão para que as alterações entrem em vigor.

Essas variáveis podem ser configuradas no arquivo de configuração do MySQL (`my.cnf` "linux" ou `my.ini` "windows") ou diretamente através de comandos SQL usando a instrução `SET`.

As variáveis podem ser agrupadas em duas diretivas dentro do arquivo de configuração:
- `[mysqld]`: para variáveis globais do MySQL.
- `[client]`: para variáveis locais do cliente MySQL.

Site de documentação de variáveis: https://dev.mysql.com/doc/refman/8.4/en/server-system-variables.html

Para pesquisar por uma variável específica, pode-se usar o comando:

```sql
SHOW VARIABLES LIKE 'nome_da_variavel';
# exemplo:
SHOW VARIABLES LIKE 'max_connections';
```

A variável `max_connections` define o número máximo de conexões simultâneas permitidas ao servidor MySQL. O valor padrão é 151, mas pode ser ajustado conforme a necessidade do ambiente. Para definí-la é preciso refletir sobre quantos usuários ou aplicações irão se conectar ao banco de dados ao mesmo tempo. Para isso é importante monitorar o uso de conexões ativas ao longo do tempo para identificar picos de demanda "quando está sendo atingido muitas vezes o limite máximo" e ajustar esse valor adequadamente.

Para entender quantas conexões estão ativas no momento, pode-se usar o seguinte comando SQL que é a sugestão oficial do MySQL:
```sql
SHOW STATUS WHERE variable_name = 'Threads_connected';
```

Este comando retorna o número atual de conexões ativas ao servidor MySQL. Monitorar essa métrica regularmente ajuda a identificar se o valor de `max_connections` está adequado ou se precisa ser ajustado para evitar problemas de conexão.

Outra forma de verificar as conexões ativas em detalhe é utilizando o comando:
```sql
SHOW PROCESSLIST;
```

Para definir o valor da variável `max_connections`, pode-se usar o seguinte comando SQL:
```sql
SET GLOBAL max_connections = 200;
```

## Tabelas temporárias

O uso de tabelas temporárias é fundamental para ajudar na performance de consultas complexas no MySQL. São usadas em diversos contextos de consulta como Seleção, Inclusão, Alteração e Exclusão de dados e isto influencia no desempenho da base de dados.

Elas são criadas automaticamente pelo servidor MySQL quando uma consulta requer armazenamento intermediário de dados.

Quando temos uma limitação de memória para operações temporárias, o MySQL cria tabelas temporárias no disco, o que pode ser mais lento do que manter essas tabelas na memória e pode causar problemas de performance. Para otimizar o desempenho, é possível ajustar as variáveis `tmp_table_size` e `max_heap_table_size`, que definem o tamanho máximo permitido para tabelas temporárias na memória. Se uma tabela temporária exceder esse tamanho, ela será criada no disco.

Para garantir que está corretamente configurado é necessário monitorar as tabelas temporárias que estão sendo criadas no disco com o seguinte comando:

```sql
SHOW GLOBAL STATUS LIKE 'Created_tmp_disk_tables';
```

Caso esteja atingindo um número elevado de tabelas temporárias no disco, é recomendável aumentar os valores das variáveis `tmp_table_size` e `max_heap_table_size` para permitir que mais tabelas temporárias sejam mantidas na memória, melhorando assim a performance das consultas. Manter sempre um mínimo de tabelas temporárias em disco é essencial para garantir a eficiência do banco de dados.

Para verificar tabelas temporárias em memória, pode-se usar o comando:

```sql
SHOW GLOBAL STATUS LIKE 'Created_tmp_tables';
```


## InnoDB

É a forma mais eficiente de armazenar dados no banco. E a forma de armazenamento é importante para configuração e monitoramento do ambiente MySQL. E existem várias formas de armazenar dados no disco, mais existem dois tipos principais de armazenamento no MySQL: **InnoDB** e **MyISAM**.

A versão 8 do MySQL utiliza o InnoDB como mecanismo de armazenamento padrão, devido às suas vantagens em termos de desempenho, confiabilidade e suporte a transações. Porque ele é mais preparado para se recuperar de falhas, suporta restrições de chaves estrangeiras e bloqueia a linha ao invés de bloquear a tabela inteira durante acesso simultâneo de dados por múltiplos usuários, o que melhora a concorrência e o desempenho em ambientes com múltiplas conexões simultâneas.

Associado ao InnoDB existe a variável `innodb_buffer_pool_size`, que é a área de memória onde o InnoDB armazena dados e índices em cache para melhorar o desempenho das operações de leitura e escrita. O ajuste do tamanho do buffer melhora o desempenho de consultas, permitindo que mais dados sejam mantidos na memória, reduzindo a necessidade de acesso ao disco, mas se for ultilizado um valor muito alto, pode causar falta de memória para outras operações do sistema. O tamanho ideal dessa variável leva em conta a quantidade total de memória RAM disponível no servidor, o tamanho do banco de dados que são acessados com mais frequência e a carga de trabalho esperada. 

Geralmente, recomenda-se configurar o `innodb_buffer_pool_size` para cerca de 70-80% da memória RAM total em servidores dedicados ao MySQL e desde que o tamanho total do banco de dados não exceda a capacidade de memória em disco disponível.


## Estimando tamanho de tabelas

É possível estimar o tamanho total de uma tabela no MySQL utilizando a seguinte consulta SQL:

```sql
SELECT (DATA_LENGTH + INDEX_LENGTH) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'nome_do_banco_de_dados' AND TABLE_NAME = 'nome_da_tabela';
```

É possível estimar o tamanho médio de cada linha da tabela no MySQL utilizando a seguinte consulta SQL:

```sql
SELECT (DATA_LENGTH + INDEX_LENGTH)/ (SELECT COUNT(*) FROM nome_da_tabela) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'nome_do_banco_de_dados' AND TABLE_NAME = 'nome_da_tabela';
```

Com este tamanho médio é possível estimar o tamanho da tabela e MB a partir da quantidade de dados estimados esperados para a mesma, exemplo:

```sql
# quantidade de linhas esperadas * Tamanho médio da linha 
# 1milhão de linhas
SELECT (1000000 * ((DATA_LENGTH + INDEX_LENGTH)/ (SELECT COUNT(*) FROM nome_da_tabela))
    / (1024 * 1024)) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'nome_do_banco_de_dados' AND TABLE_NAME = 'nome_da_tabela';
```


## Tablespaces

É uma estrututura de armazenamento de dados que contém tabelas, índices e outros objetos de banco de dados. No MySQL, os tablespaces são usados principalmente com o mecanismo de armazenamento InnoDB para gerenciar como os dados são armazenados no disco.

As bases do formato InnoDB podem ser armazenadas em um ou mais tablespaces. Esses tablespaces podem ser do tipo compartilhado ou dedicado, para cada tabela.

Com o uso de tablespaces, é possível por exemplo, alocar diferentes tabelas ou índices para diferentes dispositivos de armazenamento, otimizando o desempenho e a utilização do espaço em disco.

Comando para criar um tablespace:
```sql
CREATE TABLESPACE nome_do_tablespace ADD DATAFILE 'nome_do_tablespace.ibd' ENGINE=InnoDB;
```

Comando para verificar detalhes da nova tablespace:
```sql
SELECT * FROM INFORMATION_SCHEMA.INNODB_TABLESPACES;
```

## Performance de consultas

