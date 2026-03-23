import { Text, View } from 'react-native';

export default function MatchesScreen() {
  return (
    <View className="flex-1 items-center justify-center bg-background">
      <View className="bg-surface rounded-2xl p-6 shadow-sm items-center">
        <Text className="text-2xl font-bold text-text-primary">Matches</Text>
        <Text className="text-base text-text-secondary mt-2">Your family connections</Text>
      </View>
    </View>
  );
}
