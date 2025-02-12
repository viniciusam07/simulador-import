// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application";
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading";

// Carrega os controladores automaticamente
eagerLoadControllersFrom("controllers", application);

// Importa e registra manualmente o controlador do autocomplete NCM
import NcmAutocomplete from "controllers/ncm_autocomplete";
application.register("ncm-autocomplete", NcmAutocomplete);

// Importa e registra manualmente o controlador do formulário de despesas
import ExpenseFormController from "controllers/expense_form_controller";
application.register("expense-form", ExpenseFormController);

// Importa e registra controllers
import ModalController from "controllers/modal_controller";
application.register("modal", ModalController);

// CNPJ
import CnpjController from "controllers/cnpj_controller";
application.register("cnpj", CnpjController);

// Simulation Schedule
import SimulationScheduleController from "controllers/simulation_schedule_controller";
application.register("simulation-schedule", SimulationScheduleController);
