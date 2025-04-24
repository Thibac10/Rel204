# Rel940

O REL940 trata-se de um shell para uso exclusivo de linha de comando (CLI). A forma como está implementado aqui apresenta comandos para criação de relatórios e chamadas de scripts externos com um visual limpo e "amigável". Esse shell foi criado para ser um centralizador de tarefas em lotes.

Os parâmetros aqui presentes estão apenas para exemplo. Com certeza esses serão alterados/adaptados para seu uso.

A execução do shell é simples, e possui apenas dois parametros adicionais de execução:

## Execução:

user@machine # 
```rel940.sh -noemail -noprint```

`-noemail` : Executa o shell sem o envio de e-mails.

`-noprint` : Executa o shell sem impressões de relatórios.


Vamos então ao processo de instalação:

## Instalação

A instalação é simples e requer apenas que seja configurado os arquivos e diretórios declarados na área de VARIÁVEIS marcados como `CONFIG` no início do shell rel940. Como mencionado anteriormente, tudo aqui será adaptado de acordo com a necessidade de quem estiver implementando.

#### Sugestão de Estrutura de Diretórios:

**DIRETÓRIO RAIZ:**

```
- rel940.sh           (shell principal para execução)
- modules             (diretório onde ficam os modulos do rel940)
- logs                (diretório de logs)
- relatorios_diarios  (diretório destino dos relatórios gerados)
- imprimir            (diretório onde serão armazenados os documentos que foram impressos)
```
