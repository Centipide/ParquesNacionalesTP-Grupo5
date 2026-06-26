package com.unlam.parques.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.unlam.parques.model.Visitante;
import com.unlam.parques.service.VisitanteService;

@Controller
@RequestMapping("/visitantes") // La URL base en el navegador será http://localhost:8090/visitantes
public class VisitanteController {

    @Autowired
    private VisitanteService service;

    // 1. LISTAR: Trae los visitantes de la base y los monta en la grilla HTML
    @GetMapping
    public String listar(Model model) {
        model.addAttribute("listaVisitantes", service.listar());
        return "visitantes/lista"; // Va a buscar el archivo lista.html
    }

    // 2. FORMULARIO NUEVO: Abre la pantalla con un molde de Visitante vacío para el Alta
    @GetMapping("/nuevo")
    public String mostrarFormularioNuevo(Model model) {
        model.addAttribute("visitante", new Visitante());
        return "visitantes/formulario"; // Va a buscar el archivo formulario.html
    }

    // 3. GUARDAR: Recibe los datos del HTML y llama al servicio para ejecutar tu SP
    @PostMapping("/guardar")
    public String guardar(@ModelAttribute("visitante") Visitante v) {
        service.guardar(v);
        return "redirect:/visitantes"; // Redirecciona a la grilla principal
    }

    // 4. FORMULARIO EDITAR: Busca al visitante por ID y lo carga en las cajas de texto para modificar
    @GetMapping("/editar/{id}")
    public String mostrarFormularioEditar(@PathVariable("id") Integer id, Model model) {
        model.addAttribute("visitante", service.buscar(id));
        return "visitantes/formulario"; // Reutiliza el mismo formulario.html
    }

    // 5. ELIMINAR: Captura el ID de la fila elegida y llama a tu SP de borrado controlado
    @GetMapping("/eliminar/{id}")
    public String eliminar(@PathVariable("id") Integer id) {
        service.eliminar(id);
        return "redirect:/visitantes";
    }
    
    
    //////////////////////////////////////////
    @GetMapping("/reporte-xml")
    public org.springframework.http.ResponseEntity<byte[]> descargarReporteXml() {
        try {
            // Capturamos el String estructurado que escupe el SP
            String xmlContent = service.obtenerMatrizVisitasXml();
            byte[] data = xmlContent.getBytes(java.nio.charset.StandardCharsets.UTF_8);

            // Configuramos las cabeceras HTTP de descarga automática
            org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
            headers.setContentType(org.springframework.http.MediaType.APPLICATION_XML);
            headers.setContentDispositionFormData("attachment", "reporte_matriz_visitas.xml");

            return new org.springframework.http.ResponseEntity<>(data, headers, org.springframework.http.HttpStatus.OK);
        } catch (Exception e) {
            return new org.springframework.http.ResponseEntity<>(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
}