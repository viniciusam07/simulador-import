class AddMissingFieldsToSimulationQuotations < ActiveRecord::Migration[7.1]
  def change
    # Adiciona `customs_total_value` se não existir
    unless column_exists?(:simulation_quotations, :customs_total_value)
      add_column :simulation_quotations, :customs_total_value, :decimal, precision: 10, scale: 2
    end

    # Adiciona `customs_unit_value` se não existir
    unless column_exists?(:simulation_quotations, :customs_unit_value)
      add_column :simulation_quotations, :customs_unit_value, :decimal, precision: 10, scale: 2
    end

    # Adiciona `freight_allocated` se não existir
    unless column_exists?(:simulation_quotations, :freight_allocated)
      add_column :simulation_quotations, :freight_allocated, :decimal, precision: 10, scale: 2
    end

    # Adiciona `insurance_allocated` se não existir
    unless column_exists?(:simulation_quotations, :insurance_allocated)
      add_column :simulation_quotations, :insurance_allocated, :decimal, precision: 10, scale: 2
    end

    # Adiciona `tributo_ii` se não existir
    unless column_exists?(:simulation_quotations, :tributo_ii)
      add_column :simulation_quotations, :tributo_ii, :decimal, precision: 10, scale: 2
    end

    # Adiciona `tributo_ipi` se não existir
    unless column_exists?(:simulation_quotations, :tributo_ipi)
      add_column :simulation_quotations, :tributo_ipi, :decimal, precision: 10, scale: 2
    end

    # Adiciona `tributo_pis` se não existir
    unless column_exists?(:simulation_quotations, :tributo_pis)
      add_column :simulation_quotations, :tributo_pis, :decimal, precision: 10, scale: 2
    end

    # Adiciona `tributo_cofins` se não existir
    unless column_exists?(:simulation_quotations, :tributo_cofins)
      add_column :simulation_quotations, :tributo_cofins, :decimal, precision: 10, scale: 2
    end

    # Adiciona `tributo_icms` se não existir
    unless column_exists?(:simulation_quotations, :tributo_icms)
      add_column :simulation_quotations, :tributo_icms, :decimal, precision: 10, scale: 2
    end
  end
end
