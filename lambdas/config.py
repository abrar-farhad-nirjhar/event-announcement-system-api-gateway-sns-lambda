import dataclasses
import os


@dataclasses.dataclass(frozen=True)
class Config:
    SNS_ARN: str

    @classmethod
    def from_env(cls) -> "Config":
        return cls(
            SNS_ARN=os.getenv("EVENT_SNS_ARN", ""),
        )


config = Config.from_env()
