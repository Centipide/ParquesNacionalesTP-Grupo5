package com.unlam.parques.service;

import com.unlam.parques.model.Visitante;
import com.unlam.parques.repository.VisitanteRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.StoredProcedureQuery;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
public class VisitanteService {

    @Autowired
    private VisitanteRepository repo;

    @PersistenceContext
    private EntityManager em;

    public List<Visitante> listar() {
        return repo.findAll();
    }

    public Visitante buscar(Integer id) {
        return repo.findById(id).orElseThrow(() -> new RuntimeException("Visitante no encontrado"));
    }

    @Transactional
    public void guardar(Visitante v) {
        if (v.getIdVisitante() == null) {
            StoredProcedureQuery sp = em.createStoredProcedureQuery("Ventas.sp_AltaVisitante");
            sp.registerStoredProcedureParameter("nombre", String.class, jakarta.persistence.ParameterMode.IN);
            sp.registerStoredProcedureParameter("apellido", String.class, jakarta.persistence.ParameterMode.IN);
            sp.registerStoredProcedureParameter("email", String.class, jakarta.persistence.ParameterMode.IN);
            sp.registerStoredProcedureParameter("direccion", String.class, jakarta.persistence.ParameterMode.IN);
            sp.registerStoredProcedureParameter("telefono", String.class, jakarta.persistence.ParameterMode.IN);

            sp.setParameter("nombre", v.getNombre());
            sp.setParameter("apellido", v.getApellido());
            sp.setParameter("email", v.getEmail());
            sp.setParameter("direccion", v.getDireccion());
            sp.setParameter("telefono", v.getTelefono());
            sp.execute();
        } else {
            StoredProcedureQuery sp = em.createStoredProcedureQuery("Ventas.sp_ModificacionVisitante");
            sp.registerStoredProcedureParameter("idVisitante", Integer.class, jakarta.persistence.ParameterMode.IN);
            sp.registerStoredProcedureParameter("nombre", String.class, jakarta.persistence.ParameterMode.IN);
            sp.registerStoredProcedureParameter("apellido", String.class, jakarta.persistence.ParameterMode.IN);
            sp.registerStoredProcedureParameter("email", String.class, jakarta.persistence.ParameterMode.IN);
            sp.registerStoredProcedureParameter("direccion", String.class, jakarta.persistence.ParameterMode.IN);
            sp.registerStoredProcedureParameter("telefono", String.class, jakarta.persistence.ParameterMode.IN);

            sp.setParameter("idVisitante", v.getIdVisitante());
            sp.setParameter("nombre", v.getNombre());
            sp.setParameter("apellido", v.getApellido());
            sp.setParameter("email", v.getEmail());
            sp.setParameter("direccion", v.getDireccion());
            sp.setParameter("telefono", v.getTelefono());
            sp.execute();
        }
    }

    @Transactional
    public void eliminar(Integer id) {
        StoredProcedureQuery sp = em.createStoredProcedureQuery("Ventas.sp_EliminarVisitante");
        sp.registerStoredProcedureParameter("idVisitante", Integer.class, jakarta.persistence.ParameterMode.IN);
        sp.setParameter("idVisitante", id);
        sp.execute();
    }
    
 //ENTREGA 7: Invoca el SP nativo de matriz de visitas en formato XML
    @org.springframework.transaction.annotation.Transactional(readOnly = true)
    public String obtenerMatrizVisitasXml() {
        try {
            // Ejecutamos el SP nativo pasándole el año actual (2026) como parámetro
            jakarta.persistence.Query query = em.createNativeQuery("EXEC Reportes.sp_MatrizVisitasXML :anio");
            query.setParameter("anio", 2026);
            
            Object resultado = query.getSingleResult();
            return resultado != null ? resultado.toString() : "<Reporte>Sin datos de visitas</Reporte>";
        } catch (Exception e) {
            return "<Reporte><Error>" + e.getMessage() + "</Error></Reporte>";
        }
    }
}