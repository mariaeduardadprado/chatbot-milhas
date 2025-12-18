def calculate_mile_value(price_cash: float, price_miles: int, tax_cash: float = 0.0) -> str:
    """
    Calcula o valor do milheiro (CPM) para comparar se vale a pena usar milhas ou dinheiro.
    
    Args:
        price_cash (float): O preço da passagem em Reais (R$).
        price_miles (int): A quantidade de milhas necessária para a passagem.
        tax_cash (float): O valor das taxas de embarque em Reais (R$).
    
    Returns:
        str: Uma análise detalhada do CPM (Custo por Mil Milhas).
    """
    print(f"TOOL EXECUTION: Calculando CPM para R${price_cash} vs {price_miles} milhas...")

    # Lógica: (Preço em Dinheiro - Taxas) / (Milhas / 1000)
    net_price = price_cash - tax_cash
    cpm = (net_price / price_miles) * 1000
    
    result = (
        f"Análise de Valor:\n"
        f"- Preço Líquido (sem taxas): R$ {net_price:.2f}\n"
        f"- Valor de cada 1.000 milhas nesta emissão: R$ {cpm:.2f}\n"
    )
    
    if cpm > 20:
        result += "Veredito: Excelente! As milhas estão valendo mais que o mercado (R$ 20,00)."
    elif cpm > 14:
        result += "Veredito: Aceitável. É um uso razoável das milhas."
    else:
        result += "Veredito: Não vale a pena. Melhor pagar em dinheiro e guardar as milhas."
        
    return result