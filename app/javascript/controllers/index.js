// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application";
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading";

// Carrega os controladores automaticamente
eagerLoadControllersFrom("controllers", application);

// Importa e registra manualmente o controlador do autocomplete NCM
import NcmAutocomplete from "./ncm_autocomplete";
application.register("ncm-autocomplete", NcmAutocomplete);

// Importa e registra manualmente o controlador do formulário de despesas
import ExpenseFormController from "./expense_form_controller";
application.register("expense-form", ExpenseFormController);
