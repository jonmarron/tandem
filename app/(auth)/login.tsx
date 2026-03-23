import { Text, View } from 'react-native';

export default function LoginScreen() {
  return (
    <View className="flex-1 items-center justify-center bg-background px-6">
      <Text className="text-3xl font-bold text-text-primary mb-2">Welcome back</Text>
      <Text className="text-base text-text-secondary">Sign in to FamilyMatch</Text>
    </View>
  );
}
