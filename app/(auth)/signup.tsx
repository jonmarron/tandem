import { Link } from 'expo-router';
import { useState } from 'react';
import { ActivityIndicator, Pressable, Text, TextInput, View } from 'react-native';

import { useAuth } from '@/lib/auth';

export default function SignupScreen() {
  const { signUp } = useAuth();
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function handleSignUp() {
    if (!fullName || !email || !password) {
      setError('Please fill in all fields.');
      return;
    }
    if (password.length < 6) {
      setError('Password must be at least 6 characters.');
      return;
    }
    setLoading(true);
    setError(null);
    const { error } = await signUp(email.trim(), password, fullName.trim());
    setLoading(false);
    if (error) setError(error);
  }

  return (
    <View className="flex-1 justify-center bg-background px-6">
      <Text className="text-3xl font-bold text-text-primary mb-1">Create account</Text>
      <Text className="text-base text-text-secondary mb-8">Join FamilyMatch</Text>

      <Text className="text-sm font-medium text-text-primary mb-1">Full name</Text>
      <TextInput
        className="bg-surface border border-border rounded-xl px-4 py-3 text-text-primary mb-4"
        placeholder="Jane Smith"
        placeholderTextColor="#9CA3AF"
        autoCapitalize="words"
        value={fullName}
        onChangeText={setFullName}
      />

      <Text className="text-sm font-medium text-text-primary mb-1">Email</Text>
      <TextInput
        className="bg-surface border border-border rounded-xl px-4 py-3 text-text-primary mb-4"
        placeholder="you@example.com"
        placeholderTextColor="#9CA3AF"
        autoCapitalize="none"
        keyboardType="email-address"
        value={email}
        onChangeText={setEmail}
      />

      <Text className="text-sm font-medium text-text-primary mb-1">Password</Text>
      <TextInput
        className="bg-surface border border-border rounded-xl px-4 py-3 text-text-primary mb-4"
        placeholder="Min. 6 characters"
        placeholderTextColor="#9CA3AF"
        secureTextEntry
        value={password}
        onChangeText={setPassword}
      />

      {error && (
        <Text className="text-error text-sm mb-4">{error}</Text>
      )}

      <Pressable
        className="bg-primary rounded-xl py-4 items-center mb-4"
        onPress={handleSignUp}
        disabled={loading}
      >
        {loading
          ? <ActivityIndicator color="#fff" />
          : <Text className="text-white font-semibold text-base">Create account</Text>
        }
      </Pressable>

      <View className="flex-row justify-center">
        <Text className="text-text-secondary">Already have an account? </Text>
        <Link href="/(auth)/login">
          <Text className="text-primary font-semibold">Sign in</Text>
        </Link>
      </View>
    </View>
  );
}
