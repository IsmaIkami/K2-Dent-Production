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

const SUPABASE_CONFIG = {
  url: '', // TO FILL: https://YOUR-PROJECT.supabase.co
  anonKey: '', // TO FILL: Your anon/public key
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

// Initialize Supabase client
let supabase = null;

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
    supabase = window.supabase.createClient(
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
        const { data, error } = await supabase
          .from('patients')
          .update(patient)
          .eq('id', patient.id)
          .select()
          .single();

        if (error) throw error;
        return data;
      } else {
        // Create new
        const { data, error } = await supabase
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
      const { error } = await supabase
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
   * Search patients
   * @param {string} query - Search query
   * @returns {Promise<Array>} Matching patients
   */
  async searchPatients(query) {
    try {
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
        .from('timeline_events')
        .insert([{
          patient_id: patientId,
          event_type: event.type,
          title: event.title,
          description: event.description || '',
          badge: event.badge || '',
          event_data: event.data || {}
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
        const { data, error } = await supabase
          .from('appointments')
          .update(appointment)
          .eq('id', appointment.id)
          .select()
          .single();

        if (error) throw error;
        return data;
      } else {
        // Create
        const { data, error } = await supabase
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
      const { data, error } = await supabase
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
        supabase.from('patients').select('*', { count: 'exact', head: true }),
        supabase.from('appointments').select('*', { count: 'exact', head: true }).eq('appointment_date', new Date().toISOString().split('T')[0]),
        supabase.from('inami_acts').select('*', { count: 'exact', head: true }).gte('act_date', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0])
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
    return supabase
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
    return supabase
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
    return supabase.removeChannel(subscription);
  }
};

// ============================================================================
// EXPORT
// ============================================================================

// Make available globally
window.DB = DB;
window.Realtime = Realtime;
window.initSupabase = initSupabase;

// Auto-initialize if config is set
if (SUPABASE_CONFIG.url && SUPABASE_CONFIG.anonKey) {
  initSupabase();
}

console.log('📦 K2 Dent - Supabase Client loaded');
