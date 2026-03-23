import { createClient } from '@supabase/supabase-js';
import * as SecureStore from 'expo-secure-store';
import { LogBox, Platform } from 'react-native';

import type { Database } from './types/database';

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL ?? '';
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY ?? '';

const isConfigured = supabaseUrl.startsWith('http') && supabaseAnonKey.length > 0;

if (__DEV__ && !isConfigured) {
  console.warn(
    '[Supabase] Missing env vars — copy .env.local.example to .env.local and restart with --clear.'
  );
}

// Suppress the intermediate unhandled-rejection noise that React Native's
// tracker fires before our promise chain has a chance to handle the error.
if (__DEV__) {
  LogBox.ignoreLogs(['Network request failed']);
}

const ExpoSecureStoreAdapter = {
  getItem: (key: string) => {
    if (Platform.OS === 'web') return Promise.resolve(localStorage.getItem(key));
    return SecureStore.getItemAsync(key);
  },
  setItem: (key: string, value: string) => {
    if (Platform.OS === 'web') { localStorage.setItem(key, value); return Promise.resolve(); }
    return SecureStore.setItemAsync(key, value);
  },
  removeItem: (key: string) => {
    if (Platform.OS === 'web') { localStorage.removeItem(key); return Promise.resolve(); }
    return SecureStore.deleteItemAsync(key);
  },
};

export const supabase = createClient<Database>(
  supabaseUrl || 'http://localhost',
  supabaseAnonKey || 'placeholder',
  {
    auth: {
      storage: ExpoSecureStoreAdapter,
      autoRefreshToken: isConfigured,
      persistSession: isConfigured,
      detectSessionInUrl: false,
    },
    global: {
      // Wrap fetch in a new Promise so the inner fetch promise is always
      // considered "handled" before React Native's rejection tracker fires.
      // whatwg-fetch rejects via setTimeout which races the tracker otherwise.
      fetch: (url, options) =>
        new Promise((resolve, reject) => {
          const controller = new AbortController();
          const timeoutId = setTimeout(() => controller.abort(), 10000);
          fetch(url, { ...options, signal: controller.signal })
            .then(resolve)
            .catch(err => {
              if (err.name === 'AbortError') {
                reject(new Error('Supabase request timed out'));
              } else {
                reject(err);
              }
            })
            .finally(() => clearTimeout(timeoutId));
        }),
    },
  }
);
