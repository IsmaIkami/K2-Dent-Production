/**
 * K2 DENT — SUPABASE CLIENT
 * Cloud database integration with PostgreSQL
 *
 * @author Ismail Sialyen
 * @date April 2026
 * @version 1.0.0
 * @powered-by Supabase (PostgreSQL)
 */

// ============================================================================
// CONFIGURATION
// ============================================================================

// Use configuration from config.js (window.K2_CONFIG)
const SUPABASE_CONFIG = {
  get url() {
    return window.K2_CONFIG?.SUPABASE_URL || '';
  },
  get anonKey() {
    return window.K2_CONFIG?.SUPABASE_ANON_KEY || '';
  },
  options: {
    auth: {
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: true
    },
    db: {
      schema: 'public'
    },
    global: {
      headers: { 'x-application': 'k2-dent' }
    }
  }
};

// Initialize Supabase client (renamed to avoid Safari error with global 'supabase')
let supabaseClient = null;

/**
 * Initialize Supabase connection
 * Call this once at app startup
 */
function initSupabase() {
  if (!SUPABASE_CONFIG.url || !SUPABASE_CONFIG.anonKey) {
    console.error('⚠️ Supabase not configured! Please set URL and ANON_KEY in js/supabase-client.js');
    return false;
  }

  try {
    supabaseClient = window.supabase.createClient(
      SUPABASE_CONFIG.url,
      SUPABASE_CONFIG.anonKey,
      SUPABASE_CONFIG.options
    );
    console.log('✅ Supabase initialized successfully');
    return true;
  } catch (error) {
    console.error('❌ Supabase initialization failed:', error);
    return false;
  }
}

// ============================================================================
// DATABASE MANAGER
// ============================================================================

const DB = {

  // ========================================================================
  // PATIENTS
  // ========================================================================

  /**
   * Get all patients
   * @returns {Promise<Array>} List of patients
   */
  async getAllPatients() {
    try {
      const { data, error } = await supabaseClient
        .from('patients')
        .select('*')
        .order('last_name', { ascending: true });

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Error fetching patients:', error);
      throw error;
    }
  },

  /**
   * Get patient by ID
   * @param {string} id - Patient UUID
   * @returns {Promise<Object>} Patient object
   */
  async getPatient(id) {
    try {
      const { data, error } = await supabaseClient
        .from('patients')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error fetching patient:', error);
      throw error;
    }
  },

  /**
   * Get patient by NISS
   * @param {string} niss - Belgian NISS number
   * @returns {Promise<Object>} Patient object
   */
  async getPatientByNISS(niss) {
    try {
      const { data, error } = await supabaseClient
        .from('patients')
        .select('*')
        .eq('niss', niss)
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error fetching patient by NISS:', error);
      throw error;
    }
  },

  /**
   * Save patient (create or update)
   * @param {Object} patient - Patient data
   * @returns {Promise<Object>} Saved patient
   */
  async savePatient(patient) {
    try {
      if (patient.id) {
        // Update existing
        const { data, error } = await supabaseClient
          .from('patients')
          .update(patient)
          .eq('id', patient.id)
          .select()
          .single();

        if (error) throw error;
        return data;
      } else {
        // Create new
        const { data, error } = await supabaseClient
          .from('patients')
          .insert([patient])
          .select()
          .single();

        if (error) throw error;
        return data;
      }
    } catch (error) {
      console.error('Error saving patient:', error);
      throw error;
    }
  },

  /**
   * Delete patient
   * @param {string} id - Patient UUID
   */
  async deletePatient(id) {
    try {
      const { error } = await supabaseClient
        .from('patients')
        .delete()
        .eq('id', id);

      if (error) throw error;
    } catch (error) {
      console.error('Error deleting patient:', error);
      throw error;
    }
  },

  /**
   * Update patient fields
   * @param {string} id - Patient UUID
   * @param {Object} updates - Fields to update
   * @returns {Promise<Object>} Updated patient
   */
  async updatePatient(id, updates) {
    try {
      const { data, error } = await supabaseClient
        .from('patients')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error updating patient:', error);
      throw error;
    }
  },

  /**
   * Search patients
   * @param {string} query - Search query
   * @returns {Promise<Array>} Matching patients
   */
  async searchPatients(query) {
    try {
      const { data, error } = await supabaseClient
        .from('patients')
        .select('*')
        .or(`first_name.ilike.%${query}%,last_name.ilike.%${query}%,niss.ilike.%${query}%`)
        .order('last_name', { ascending: true })
        .limit(50);

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Error searching patients:', error);
      throw error;
    }
  },

  // ========================================================================
  // ANAMNESIS
  // ========================================================================

  /**
   * Save anamnesis (auto-versioned)
   * @param {string} patientId - Patient UUID
   * @param {string} content - Anamnesis content (markdown)
   * @param {string} type - 'AI', 'MODIFIED', or 'MANUAL'
   * @param {string} transcription - Optional transcription
   * @param {number} duration - Recording duration in seconds
   * @returns {Promise<Object>} Saved anamnesis
   */
  async saveAnamnesis(patientId, content, type = 'AI', transcription = null, duration = null) {
    try {
      const { data, error } = await supabaseClient
        .from('anamnesis')
        .insert([{
          patient_id: patientId,
          content: content,
          type: type,
          transcription: transcription,
          recording_duration: duration
        }])
        .select()
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error saving anamnesis:', error);
      throw error;
    }
  },

  /**
   * Get patient's anamnesis history
   * @param {string} patientId - Patient UUID
   * @returns {Promise<Array>} Anamnesis versions
   */
  async getPatientAnamnesis(patientId) {
    try {
      const { data, error } = await supabaseClient
        .from('anamnesis')
        .select('*')
        .eq('patient_id', patientId)
        .order('version', { ascending: false });

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Error fetching anamnesis:', error);
      throw error;
    }
  },

  /**
   * Get latest anamnesis for patient
   * @param {string} patientId - Patient UUID
   * @returns {Promise<Object|null>} Latest anamnesis
   */
  async getLatestAnamnesis(patientId) {
    try {
      const { data, error } = await supabaseClient
        .from('anamnesis')
        .select('*')
        .eq('patient_id', patientId)
        .order('version', { ascending: false })
        .limit(1)
        .single();

      if (error && error.code !== 'PGRST116') throw error; // PGRST116 = not found
      return data || null;
    } catch (error) {
      console.error('Error fetching latest anamnesis:', error);
      return null;
    }
  },

  // ========================================================================
  // TIMELINE
  // ========================================================================

  /**
   * Add event to patient timeline
   * @param {string} patientId - Patient UUID
   * @param {Object} event - Event data
   * @returns {Promise<Object>} Created event
   */
  async addTimelineEvent(patientId, event) {
    try {
      const { data, error } = await supabaseClient
        .from('timeline_events')
        .insert([{
          patient_id: patientId,
          type: event.type,
          title: event.title,
          description: event.description || '',
          badge: event.badge || '',
          related_id: event.relatedId || null,
          related_type: event.relatedType || null,
          created_by: event.createdBy || '00000000-0000-0000-0000-000000000000'
        }])
        .select()
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error adding timeline event:', error);
      throw error;
    }
  },

  /**
   * Get patient timeline
   * @param {string} patientId - Patient UUID
   * @param {number} limit - Max events to return
   * @returns {Promise<Array>} Timeline events
   */
  async getPatientTimeline(patientId, limit = 100) {
    try {
      const { data, error } = await supabaseClient
        .from('timeline_events')
        .select('*')
        .eq('patient_id', patientId)
        .order('event_date', { ascending: false })
        .limit(limit);

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Error fetching timeline:', error);
      throw error;
    }
  },

  // ========================================================================
  // DENTAL CHART
  // ========================================================================

  /**
   * Get patient's dental chart
   * @param {string} patientId - Patient UUID
   * @returns {Promise<Object>} Dental chart data
   */
  async getDentalChart(patientId) {
    try {
      const { data, error } = await supabaseClient
        .from('dental_charts')
        .select('*')
        .eq('patient_id', patientId)
        .single();

      if (error && error.code !== 'PGRST116') throw error;

      // Return empty chart if not found
      return data || {
        patient_id: patientId,
        chart_data: {},
        last_updated: new Date().toISOString()
      };
    } catch (error) {
      console.error('Error fetching dental chart:', error);
      throw error;
    }
  },

  /**
   * Save dental chart
   * @param {string} patientId - Patient UUID
   * @param {Object} chartData - Chart data (JSONB)
   * @returns {Promise<Object>} Saved chart
   */
  async saveDentalChart(patientId, chartData) {
    try {
      const { data, error } = await supabaseClient
        .from('dental_charts')
        .upsert({
          patient_id: patientId,
          chart_data: chartData,
          last_updated: new Date().toISOString()
        }, {
          onConflict: 'patient_id'
        })
        .select()
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error saving dental chart:', error);
      throw error;
    }
  },

  /**
   * Save tooth treatment
   * @param {Object} treatment - Treatment data
   * @returns {Promise<Object>} Saved treatment
   */
  async saveToothTreatment(treatment) {
    try {
      const { data, error } = await supabaseClient
        .from('tooth_treatments')
        .insert([treatment])
        .select()
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error saving treatment:', error);
      throw error;
    }
  },

  /**
   * Get patient treatments
   * @param {string} patientId - Patient UUID
   * @returns {Promise<Array>} Treatments
   */
  async getPatientTreatments(patientId) {
    try {
      const { data, error } = await supabaseClient
        .from('tooth_treatments')
        .select('*')
        .eq('patient_id', patientId)
        .order('created_at', { ascending: false });

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Error fetching treatments:', error);
      throw error;
    }
  },

  // ========================================================================
  // INAMI ACTS
  // ========================================================================

  /**
   * Save INAMI act
   * @param {Object} act - INAMI act data
   * @returns {Promise<Object>} Saved act
   */
  async saveINAMIAct(act) {
    try {
      const { data, error } = await supabaseClient
        .from('inami_acts')
        .insert([act])
        .select()
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error saving INAMI act:', error);
      throw error;
    }
  },

  /**
   * Get patient's INAMI acts
   * @param {string} patientId - Patient UUID
   * @returns {Promise<Array>} INAMI acts
   */
  async getPatientINAMIActs(patientId) {
    try {
      const { data, error } = await supabaseClient
        .from('inami_acts')
        .select('*')
        .eq('patient_id', patientId)
        .order('act_date', { ascending: false });

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Error fetching INAMI acts:', error);
      throw error;
    }
  },

  /**
   * Get all INAMI acts (recent)
   * @param {number} limit - Max acts to return
   * @returns {Promise<Array>} INAMI acts with patient info
   */
  async getAllINAMIActs(limit = 100) {
    try {
      const { data, error } = await supabaseClient
        .from('inami_acts')
        .select(`
          *,
          patients (
            first_name,
            last_name,
            niss
          )
        `)
        .order('act_date', { ascending: false })
        .limit(limit);

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Error fetching all INAMI acts:', error);
      throw error;
    }
  },

  // ========================================================================
  // PRESCRIPTIONS
  // ========================================================================

  /**
   * Save prescription
   * @param {Object} prescription - Prescription data
   * @returns {Promise<Object>} Saved prescription
   */
  async savePrescription(prescription) {
    try {
      const { data, error } = await supabaseClient
        .from('prescriptions')
        .insert([prescription])
        .select()
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error saving prescription:', error);
      throw error;
    }
  },

  /**
   * Get patient prescriptions
   * @param {string} patientId - Patient UUID
   * @returns {Promise<Array>} Prescriptions
   */
  async getPatientPrescriptions(patientId) {
    try {
      const { data, error } = await supabaseClient
        .from('prescriptions')
        .select('*')
        .eq('patient_id', patientId)
        .order('prescription_date', { ascending: false });

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Error fetching prescriptions:', error);
      throw error;
    }
  },

  /**
   * Get all prescriptions (with patient info)
   * @returns {Promise<Array>} All prescriptions
   */
  async getAllPrescriptions() {
    try {
      const { data, error } = await supabaseClient
        .from('prescriptions')
        .select(`
          *,
          patients (
            first_name,
            last_name
          )
        `)
        .order('prescription_date', { ascending: false });

      if (error) throw error;

      // Format patient name
      return (data || []).map(rx => ({
        ...rx,
        patient_name: rx.patients ? `${rx.patients.first_name} ${rx.patients.last_name}` : 'Patient inconnu'
      }));
    } catch (error) {
      console.error('Error fetching all prescriptions:', error);
      throw error;
    }
  },

  // ========================================================================
  // CERTIFICATES
  // ========================================================================

  /**
   * Save certificate
   * @param {Object} certificate - Certificate data
   * @returns {Promise<Object>} Saved certificate
   */
  async saveCertificate(certificate) {
    try {
      const { data, error } = await supabaseClient
        .from('certificates')
        .insert([certificate])
        .select()
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error saving certificate:', error);
      throw error;
    }
  },

  /**
   * Get patient certificates
   * @param {string} patientId - Patient UUID
   * @returns {Promise<Array>} Certificates
   */
  async getPatientCertificates(patientId) {
    try {
      const { data, error } = await supabaseClient
        .from('certificates')
        .select('*')
        .eq('patient_id', patientId)
        .order('certificate_date', { ascending: false });

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Error fetching certificates:', error);
      throw error;
    }
  },

  // ========================================================================
  // APPOINTMENTS
  // ========================================================================

  /**
   * Save appointment
   * @param {Object} appointment - Appointment data
   * @returns {Promise<Object>} Saved appointment
   */
  async saveAppointment(appointment) {
    try {
      if (appointment.id) {
        // Update
        const { data, error } = await supabaseClient
          .from('appointments')
          .update(appointment)
          .eq('id', appointment.id)
          .select()
          .single();

        if (error) throw error;
        return data;
      } else {
        // Create
        const { data, error } = await supabaseClient
          .from('appointments')
          .insert([appointment])
          .select()
          .single();

        if (error) throw error;
        return data;
      }
    } catch (error) {
      console.error('Error saving appointment:', error);
      throw error;
    }
  },

  /**
   * Get appointments by date
   * @param {string} date - Date (YYYY-MM-DD)
   * @returns {Promise<Array>} Appointments with patient info
   */
  async getAppointmentsByDate(date) {
    try {
      const { data, error } = await supabaseClient
        .from('appointments')
        .select(`
          *,
          patients (
            first_name,
            last_name,
            phone,
            niss
          )
        `)
        .eq('appointment_date', date)
        .order('appointment_time', { ascending: true });

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Error fetching appointments:', error);
      throw error;
    }
  },

  /**
   * Get patient appointments
   * @param {string} patientId - Patient UUID
   * @returns {Promise<Array>} Appointments
   */
  async getPatientAppointments(patientId) {
    try {
      const { data, error } = await supabaseClient
        .from('appointments')
        .select('*')
        .eq('patient_id', patientId)
        .order('appointment_date', { ascending: false });

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Error fetching patient appointments:', error);
      throw error;
    }
  },

  /**
   * Get today's appointments
   * @returns {Promise<Array>} Today's appointments
   */
  async getTodaysAppointments() {
    const today = new Date().toISOString().split('T')[0];
    return this.getAppointmentsByDate(today);
  },

  // ========================================================================
  // XRAYS / IMAGES
  // ========================================================================

  /**
   * Save xray record
   * @param {Object} xray - Xray data
   * @returns {Promise<Object>} Saved xray
   */
  async saveXray(xray) {
    try {
      const { data, error } = await supabaseClient
        .from('xrays')
        .insert([xray])
        .select()
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error saving xray:', error);
      throw error;
    }
  },

  /**
   * Get patient xrays
   * @param {string} patientId - Patient UUID
   * @returns {Promise<Array>} Xrays
   */
  async getPatientXrays(patientId) {
    try {
      const { data, error } = await supabaseClient
        .from('xrays')
        .select('*')
        .eq('patient_id', patientId)
        .order('xray_date', { ascending: false });

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Error fetching xrays:', error);
      throw error;
    }
  },

  // ========================================================================
  // STATS & ANALYTICS
  // ========================================================================

  /**
   * Get dashboard statistics
   * @returns {Promise<Object>} Statistics
   */
  async getDashboardStats() {
    try {
      const [patientsResult, appointmentsResult, actsResult] = await Promise.all([
        supabaseClient.from('patients').select('*', { count: 'exact', head: true }),
        supabaseClient.from('appointments').select('*', { count: 'exact', head: true }).eq('appointment_date', new Date().toISOString().split('T')[0]),
        supabaseClient.from('inami_acts').select('*', { count: 'exact', head: true }).gte('act_date', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0])
      ]);

      return {
        totalPatients: patientsResult.count || 0,
        todaysAppointments: appointmentsResult.count || 0,
        actsLast30Days: actsResult.count || 0
      };
    } catch (error) {
      console.error('Error fetching stats:', error);
      return {
        totalPatients: 0,
        todaysAppointments: 0,
        actsLast30Days: 0
      };
    }
  },

  // ==========================================================================
  // MEDICAL HISTORY - Données médicales versionnées
  // ==========================================================================

  /**
   * Get latest medical history for a patient
   */
  async getLatestMedicalHistory(patientId) {
    try {
      const { data, error } = await supabaseClient
        .from('medical_history')
        .select('*')
        .eq('patient_id', patientId)
        .order('created_at', { ascending: false })
        .limit(1)
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      // Return null if no history exists yet
      if (error.code === 'PGRST116') return null;
      console.error('Error fetching medical history:', error);
      throw error;
    }
  },

  /**
   * Get all medical history versions for a patient
   */
  async getAllMedicalHistory(patientId) {
    try {
      const { data, error } = await supabaseClient
        .from('medical_history')
        .select('*')
        .eq('patient_id', patientId)
        .order('created_at', { ascending: false });

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Error fetching medical history versions:', error);
      throw error;
    }
  },

  /**
   * Create or update medical history (creates new version)
   */
  async saveMedicalHistory(patientId, medicalData, createdBy = '00000000-0000-0000-0000-000000000000') {
    try {
      const { data, error } = await supabaseClient.rpc('create_medical_history_version', {
        p_patient_id: patientId,
        p_allergies: medicalData.allergies || [],
        p_medications: medicalData.medications || [],
        p_medical_conditions: medicalData.medical_conditions || [],
        p_surgical_history: medicalData.surgical_history || [],
        p_dental_concerns: medicalData.dental_concerns || null,
        p_previous_dental_treatments: medicalData.previous_dental_treatments || [],
        p_dental_anxiety_level: medicalData.dental_anxiety_level || null,
        p_brushing_frequency: medicalData.brushing_frequency || null,
        p_flossing_frequency: medicalData.flossing_frequency || null,
        p_mouthwash_use: medicalData.mouthwash_use || false,
        p_practitioner_notes: medicalData.practitioner_notes || null,
        p_created_by: createdBy
      });

      if (error) throw error;
      return data; // Returns new medical_history ID
    } catch (error) {
      console.error('Error saving medical history:', error);
      throw error;
    }
  },

  /**
   * Get complete patient view (with latest medical data)
   */
  async getPatientCompleteView(patientId) {
    try {
      const { data, error } = await supabaseClient
        .from('patient_complete_view')
        .select('*')
        .eq('id', patientId)
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error fetching complete patient view:', error);
      throw error;
    }
  },

  /**
   * Export patient dossier as structured data
   * (to be used for PDF generation or export)
   */
  async exportPatientDossier(patientId) {
    try {
      const [patient, medicalHistory, timeline, prescriptions, certificates, dentalCharts, xrays] = await Promise.all([
        this.getPatient(patientId),
        this.getAllMedicalHistory(patientId),
        this.getPatientTimeline(patientId),
        this.getPatientPrescriptions(patientId),
        this.getPatientCertificates(patientId),
        this.getDentalChart(patientId),
        this.getPatientXrays(patientId)
      ]);

      return {
        patient,
        medicalHistory,
        timeline,
        prescriptions,
        certificates,
        dentalCharts,
        xrays,
        exportDate: new Date().toISOString(),
        exportedBy: 'K2 Dent v1.0.0'
      };
    } catch (error) {
      console.error('Error exporting patient dossier:', error);
      throw error;
    }
  }
};

// ============================================================================
// REALTIME SUBSCRIPTIONS
// ============================================================================

const Realtime = {
  /**
   * Subscribe to patient changes
   * @param {function} callback - Called when patient data changes
   */
  subscribeToPatients(callback) {
    return supabaseClient
      .channel('patients-changes')
      .on('postgres_changes',
        { event: '*', schema: 'public', table: 'patients' },
        callback
      )
      .subscribe();
  },

  /**
   * Subscribe to today's appointments
   * @param {function} callback - Called when appointments change
   */
  subscribeToTodaysAppointments(callback) {
    const today = new Date().toISOString().split('T')[0];
    return supabaseClient
      .channel('appointments-today')
      .on('postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'appointments',
          filter: `appointment_date=eq.${today}`
        },
        callback
      )
      .subscribe();
  },

  /**
   * Unsubscribe from channel
   * @param {Object} subscription - Subscription object
   */
  unsubscribe(subscription) {
    return supabaseClient.removeChannel(subscription);
  }
};

// ============================================================================
// EXPORT
// ============================================================================

// Make available globally
window.supabaseClient = supabaseClient;
window.DB = DB;
window.Realtime = Realtime;
window.initSupabase = initSupabase;

// Auto-initialize if config is set
if (SUPABASE_CONFIG.url && SUPABASE_CONFIG.anonKey) {
  const initialized = initSupabase();
  if (initialized) {
    window.supabaseClient = supabaseClient;
    console.log('✅ Supabase client available at window.supabaseClient');
  }
}

console.log('📦 K2 Dent - Supabase Client loaded');
