
#!/bin/bash
#  SHELL PARA ALIMENTACAO PLANILHA GERENCIAL LOJAS AS    #
clear
#------------------------------------------------------------------------
# Definindo os caminhos
filialAT="183"
caminhoBI="/fs1/integra/"
caminhoSMG12="/fs1/save/bk/"
caminhoGER="/files/gerencial/administrativo/Gerencial"
data_atual=$(date +'%d%m%y')
arquivo_bi="bi${filialAT}${data_atual}"

################## SMG12 #######################

######################### BI #######################
processar_bi() {
    # Verifica se o arquivo BI existe no diretório especificado
    if [ -f "${caminhoBI}${arquivo_bi}" ]; then

        # Entrando no diretório de origem
        cd "${caminhoBI}"

        # Copia o arquivo BI para a pasta gerencial
        cp "${arquivo_bi}" "${caminhoGER}"

        # Entrando no diretório gerencial
        cd "${caminhoGER}"

        # Remove o arquivo BI ANTIGO, se existir
        if [ -f "bi${filialAT}" ]; then
            rm -f /files/gerencial/"bi${filialAT}"
        fi

        # Renomeia o novo arquivo BI
        mv "${arquivo_bi}" "bi${filialAT}"
    else
        echo "ARQUIVO BI NÃO ENCONTRADO. VERIFIQUE SE O ARQUIVO ESTÁ EM SEU DIRETÓRIO" # TODO
        sleep 5
    fi
}
# Função principal que chama as funções de processamento
main(){
    processar_bi
}
# Chamando a função principal
main
